param (
    [Parameter(Mandatory=$False)] [string] $SqlIP = "",
    [Parameter(Mandatory=$False)] [string] $SqlPass = "",
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $ODLID,

    [string]
    $InstallCloudLabsShadow,

    [string]
    $DeploymentID,
    
     [string]
  $AzureTenantID,
  
  [string]
  $AzureSubscriptionID,
  
      [string]
    $azsubscriptionid,

    [string]
    $aztenantid
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append

$vmAdminUsername="demouser"
$trainerUserName="trainer"
$trainerUserPassword="Password.!!1"

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1

InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow
Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword



# To resolve the error of https://github.com/microsoft/MCW-App-modernization/issues/68. The cause of the error is Powershell by default uses TLS 1.0 to connect to website, but website security requires TLS 1.2. You can change this behavior with running any of the below command to use all protocols. You can also specify single protocol.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

$branchName = "stage"

# Download and extract the starter solution files
# ZIP File sometimes gets corrupted
New-Item -ItemType directory -Path C:\MCW
#while((Get-ChildItem -Directory C:\MCW | Measure-Object).Count -eq 0 )
#{
#    (New-Object System.Net.WebClient).DownloadFile("https://github.com/CloudLabs-MCW/MCW-App-modernization/archive/$branchName.zip", 'C:\MCW.zip')
#    Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\MCW' -Force
#}
(New-Object System.Net.WebClient).DownloadFile("https://github.com/CloudLabs-MCW/MCW-App-modernization/archive/stage.zip", 'C:\MCW.zip')
Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\MCW' -Force

# Copy Web Site Files
Expand-Archive -LiteralPath "C:\MCW\MCW-App-modernization-stage\Hands-on lab\lab-files\web-site-publish.zip" -DestinationPath 'C:\inetpub\wwwroot' -Force

# Replace SQL Connection String
((Get-Content -path C:\inetpub\wwwroot\config.release.json -Raw) -replace 'SETCONNECTIONSTRING',"Server=$SqlIP;Database=PartsUnlimited;User Id=PUWebSite;Password=$SqlPass;") | Set-Content -Path C:\inetpub\wwwroot\config.json


#Replace Path

(Get-Content C:\MCW\MCW-App-modernization-stage\'Hands-on lab'\lab-files\ARM-template\webvm-logon-install1.ps1) -replace "replacepath","$Path" | Set-Content C:\MCW\MCW-App-modernization-stage\'Hands-on lab'\lab-files\ARM-template\webvm-logon-install1.ps1 -Verbos

# Schedule Installs for first Logon
$argument = "-File `"C:\MCW\MCW-App-modernization-stage\Hands-on lab\lab-files\ARM-template\webvm-logon-install1.ps1`""
$triggerAt = New-ScheduledTaskTrigger -AtLogOn -User demouser
$action = New-ScheduledTaskAction -Execute "powershell" -Argument $argument 
Register-ScheduledTask -TaskName "Install Lab Requirements" -Trigger $triggerAt -Action $action -User demouser


CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID

    
Replace sub and tenant id

(Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "GET-SUBSCRIPTION-ID", "$azsubscriptionid"} | Set-Content -Path "c:\LabFiles\AzureCreds.txt"
(Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "GET-TENANT-ID", "$aztenantid"} | Set-Content -Path "c:\LabFiles\AzureCreds.txt"


#Autologin
$Username = "demouser"
$Pass = "Password.1!!"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Username" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Pass" -type String

$Validstatus="Pending"  ##Failed or Successful at the last step
$Validmessage="Post Deployment is Pending"

#Set the final deployment status
CloudlabsManualAgent setStatus

Stop-Transcript  

Restart-Computer
