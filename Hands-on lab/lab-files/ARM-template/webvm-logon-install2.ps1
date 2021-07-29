Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension1.txt -Append

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


# Install App Service Migration Assistant
Wait-Install
Write-Host "Installing App Service Migration Assistant..."
Start-Process -file 'C:\AppServiceMigrationAssistant.msi ' -arg '/qn /l*v C:\asma_install.txt' -passthru | wait-process

#Validate and install dotnet

if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528049)
{
Write-Host ".Net 4.8 is already installed"
}
else
{
Do{

Write-Host "Installing .Net 4.8"

choco install dotnetfx -y -force
$data=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528049
}
Until ($data)

Write-Host "Installed .Net 4.8 successfully"
}

# Download and install Data Mirgation Assistant
(New-Object System.Net.WebClient).DownloadFile('https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi', 'C:\DataMigrationAssistant.msi')
Start-Process -file 'C:\DataMigrationAssistant.msi' -arg '/qn /l*v C:\dma_install.txt' -passthru | wait-process

# Install Edge
Wait-Install
Write-Host "Installing Edge..."
Start-Process -file 'C:\MicrosoftEdgeEnterpriseX64.msi' -arg '/qn /l*v C:\edge_install.txt' -passthru | wait-process

# Install .NET Core 3.1 SDK
Wait-Install
Write-Host "Installing .NET Core 3.1 SDK..."
$pathArgs = {C:\dotnet-sdk-3.1.406-win-x64.exe /Install /Quiet /Norestart /Logs logCore31SDK.txt}
Invoke-Command -ScriptBlock $pathArgs


#Check if Webvm ip is accessible or not
Import-Module Az

CD C:\LabFiles
$credsfilepath = ".\AzureCreds.txt"
$creds = Get-Content $credsfilepath | Out-String | ConvertFrom-StringData
$AzureUserName = "$($creds.AzureUserName)"
$AzurePassword = "$($creds.AzurePassword)"
$DeploymentID = "$($creds.DeploymentID)"
$SubscriptionId = "$($creds.AzureSubscriptionID)"
$passwd = ConvertTo-SecureString $AzurePassword -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AzureUserName, $passwd

Connect-AzAccount -Credential $cred

$vmipdetails=Get-AzPublicIpAddress -ResourceGroupName "hands-on-lab-$DeploymentID" -Name "WebVM-ip" 

$vmip=$vmipdetails.IpAddress
 
$url="http://"+$vmip

$HTTP_Request = [System.Net.WebRequest]::Create($url)

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.getResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {

    Write-Host "Website is working!!"
}
Else {

 Write-Host "Re-installing IIS"

(New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/5efd5ee8-4df6-4b99-9feb-87250f1cd09f/552f4b0b0340e447bab2f38331f833c5/dotnet-hosting-2.2.2-win.exe', 'C:\dotnet-hosting-2.2.2-win.exe')
$pathArgs = {C:\dotnet-hosting-2.2.2-win.exe /Install /Quiet /Norestart /Logs logCore22.txt}
Invoke-Command -ScriptBlock $pathArgs

iisreset /noforce 

Write-Host "Installed IIS successfully"

}

$url="http://"+$vmip

$HTTP_Request = [System.Net.WebRequest]::Create($url)

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.getResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200){
    $Validstatus="Succeeded"  ##Failed or Successful at the last step
    $Validmessage="Post Deployment is successful"
}
else{
    Write-Warning "Validation Failed - see log output"
    $Validstatus="Failed"  ##Failed or Successful at the last step
    $Validmessage="Post Deployment Failed"

}

CloudlabsManualAgent setStatus

CloudLabsManualAgent Start

Unregister-ScheduledTask -TaskName "Install Lab Requirements" -Confirm:$false

Stop-Transcript
