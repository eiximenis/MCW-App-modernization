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
$azsubscriptionid,
  
  [string]
  $aztenantid
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append

$vmAdminUsername="demouser"
$trainerUserName="trainer"
$trainerUserPassword="Password.!!1"

function Wait-Install {
    $msiRunning = 1
    $msiMessage = ""
    while($msiRunning -ne 0)
    {
        try
        {
            $Mutex = [System.Threading.Mutex]::OpenExisting("Global\_MSIExecute");
            $Mutex.Dispose();
            $DST = Get-Date
            $msiMessage = "An installer is currently running. Please wait...$DST"
            Write-Host $msiMessage 
            $msiRunning = 1
        }
        catch
        {
            $msiRunning = 0
        }
        Start-Sleep -Seconds 1
    }
}

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1

InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow



# To resolve the error of https://github.com/microsoft/MCW-App-modernization/issues/68. The cause of the error is Powershell by default uses TLS 1.0 to connect to website, but website security requires TLS 1.2. You can change this behavior with running any of the below command to use all protocols. You can also specify single protocol.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

Install-WindowsFeature -name Web-Server -IncludeManagementTools

	$branchName = "prod-1"
# Download and extract the starter solution files
# ZIP File sometimes gets corrupted
Write-Host "Downloading MCW-App-modernization from GitHub" -ForegroundColor Green
New-Item -ItemType directory -Path C:\MCW
while((Get-ChildItem -Directory C:\MCW | Measure-Object).Count -eq 0 )
{
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/CloudLabs-MCW/MCW-App-modernization/zipball/$branchName", 'C:\MCW.zip')
    Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\MCW' -Force
}
#rename the random branch name
$item = get-item "c:\mcw\*"
Rename-Item $item -NewName "MCW-App-modernization-$branchName"

# Replace SQL Connection String
((Get-Content -path C:\inetpub\wwwroot\config.release.json -Raw) -replace 'SETCONNECTIONSTRING',"Server=$SqlIP;Database=PartsUnlimited;User Id=PUWebSite;Password=$SqlPass;") | Set-Content -Path C:\inetpub\wwwroot\config.json


#Replace Path

(Get-Content C:\MCW\MCW-App-modernization-$branchName\'Hands-on lab'\lab-files\ARM-template\webvm-logon-install.ps1) -replace "replacepath","$Path" | Set-Content C:\MCW\MCW-App-modernization-$branchName\'Hands-on lab'\lab-files\ARM-template\webvm-logon-install.ps1 -Verbos

# Download 3.1.4 SDK
(New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/70062b11-491c-403c-91db-9d84462ee292/5db435e39128cbb608e76bf5111ab3dc/dotnet-sdk-3.1.413-win-x64.exe', 'C:\dotnet-sdk-3.1.413-win-x64.exe')


# Schedule Installs for first Logon
$argument = "-File `"C:\MCW\MCW-App-modernization-$branchName\Hands-on lab\lab-files\ARM-template\webvm-logon-install.ps1`""
$triggerAt = New-ScheduledTaskTrigger -AtLogOn -User demouser
$action = New-ScheduledTaskAction -Execute "powershell" -Argument $argument 
Register-ScheduledTask -TaskName "Install Lab Requirements" -Trigger $triggerAt -Action $action -User demouser


# Download Windows Hosting
Wait-Install
(New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/a0da9621-68f0-439a-b617-4697ee0669e3/38eb4aa6e879b9f06b73599ea2e1535f/dotnet-hosting-5.0.10-win.exe', 'C:\dotnet-hosting-5.0.10-win.exe')
$pathArgs = {C:\dotnet-hosting-5.0.10-win.exe /Install /Quiet /Norestart /Logs logHostingPackage.txt}
Invoke-Command -ScriptBlock $pathArgs


# cred file
CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID
    
Replace sub and tenant id

(Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "GET-SUBSCRIPTION-ID", "$azsubscriptionid"} | Set-Content -Path "c:\LabFiles\AzureCreds.txt"
(Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "GET-TENANT-ID", "aztenantid"} | Set-Content -Path "c:\LabFiles\AzureCreds.txt"

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
