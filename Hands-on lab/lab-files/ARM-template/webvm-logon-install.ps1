Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension1.txt -Append

$commonscriptpath = "replacepath\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

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


# Install .NET Core 3.1 SDK
Wait-Install
Write-Host "Installing .NET Core 3.1 SDK..."
$pathArgs = {C:\dotnet-sdk-3.1.413-win-x64.exe /Install /Quiet /Norestart /Logs logCore31SDK.txt}
Invoke-Command -ScriptBlock $pathArgs

$branchName = "prod-1"

# Copy Web Site Files
Wait-Install
Write-Host "Copying default website files..."
Expand-Archive -LiteralPath "C:\MCW\MCW-App-modernization-$branchName\Hands-on lab\lab-files\web-deploy-files.zip" -DestinationPath 'C:\inetpub\wwwroot' -Force


Write-Host "Restarting IIS"
iisreset.exe /restart 

Write-Host "Re-installed IIS"

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
