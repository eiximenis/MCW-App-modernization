function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

# To resolve the error of https://github.com/microsoft/MCW-App-modernization/issues/68. The cause of the error is Powershell by default uses TLS 1.0 to connect to website, but website security requires TLS 1.2. You can change this behavior with running any of the below command to use all protocols. You can also specify single protocol.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

# Disable IE ESC
Disable-InternetExplorerESC

# Download and extract the starter solution files
Invoke-WebRequest 'https://github.com/microsoft/MCW-App-modernization/archive/master.zip' -OutFile 'C:\MCW.zip'
Expand-Archive -LiteralPath 'C:\MCW.zip' -DestinationPath 'C:\MCW' -Force

# Download and install .NET Core 2.2
Invoke-WebRequest 'https://download.visualstudio.microsoft.com/download/pr/279de74e-f7e3-426b-94d8-7f31d32a129c/e83e8c4c49bcb720def67a5c8fe0d8df/dotnet-sdk-2.2.207-win-x64.exe' -OutFile 'C:\dotnet-sdk-2.2.207-win-x64.exe'
$pathArgs = {C:\dotnet-sdk-2.2.207-win-x64.exe /Install /Quiet /Norestart /Logs log.txt}
Invoke-Command -ScriptBlock $pathArgs

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://aka.ms/ssmsfullsetup' -OutFile 'C:\SSMS-Setup.exe'
$pathArgs = {C:\SSMS-Setup.exe /Install /Quiet /Norestart /Logs log.txt}
Invoke-Command -ScriptBlock $pathArgs
