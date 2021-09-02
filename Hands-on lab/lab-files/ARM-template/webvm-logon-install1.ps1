Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension1.txt -Append

$commonscriptpath = "replacepath\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath


Write-Host "Re-installing IIS"

(New-Object System.Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/5efd5ee8-4df6-4b99-9feb-87250f1cd09f/552f4b0b0340e447bab2f38331f833c5/dotnet-hosting-2.2.2-win.exe', 'C:\dotnet-hosting-2.2.2-win.exe')
$pathArgs = {C:\dotnet-hosting-2.2.2-win.exe /Install /Quiet /Norestart /Logs logCore22.txt}
Invoke-Command -ScriptBlock $pathArgs

iisreset /noforce 

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
