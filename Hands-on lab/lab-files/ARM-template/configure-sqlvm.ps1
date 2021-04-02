param (
    [Parameter(Mandatory=$False)] [string] $SqlPass = ""
)

# Disable Internet Explorer Enhanced Security Configuration
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

# Disable IE ESC
Disable-InternetExplorerESC

# Enable SQL Server ports on the Windows firewall
function Add-SqlFirewallRule {
    $fwPolicy = $null
    $fwPolicy = New-Object -ComObject HNetCfg.FWPolicy2

    $NewRule = $null
    $NewRule = New-Object -ComObject HNetCfg.FWRule

    $NewRule.Name = "SqlServer"
    # TCP
    $NewRule.Protocol = 6
    $NewRule.LocalPorts = 1433
    $NewRule.Enabled = $True
    $NewRule.Grouping = "SQL Server"
    # ALL
    $NewRule.Profiles = 7
    # ALLOW
    $NewRule.Action = 1
    # Add the new rule
    $fwPolicy.Rules.Add($NewRule)
}

Add-SqlFirewallRule

# Attach the downloaded backup files to the local SQL Server instance
function Setup-Sql {
    #Add snap-in
    Add-PSSnapin SqlServerCmdletSnapin* -ErrorAction SilentlyContinue

    $ServerName = 'SQLSERVER2008'
    $DatabaseName = 'PartsUnlimited'
    
    $Cmd = "USE [master] CREATE DATABASE [$DatabaseName]"
    Invoke-Sqlcmd $Cmd -QueryTimeout 3600 -ServerInstance $ServerName

    Invoke-Sqlcmd "ALTER DATABASE [$DatabaseName] SET DISABLE_BROKER;" -QueryTimeout 3600 -ServerInstance $ServerName
    
    Invoke-Sqlcmd "CREATE LOGIN PUWebSite WITH PASSWORD = '$SqlPass';" -QueryTimeout 3600 -ServerInstance $ServerName
    Invoke-Sqlcmd "USE [$DatabaseName];CREATE USER PUWebSite FOR LOGIN [PUWebSite];EXEC sp_addrolemember 'db_owner', 'PUWebSite'; " -QueryTimeout 3600 -ServerInstance $ServerName

    Invoke-Sqlcmd "EXEC sp_addsrvrolemember @loginame = N'PUWebSite', @rolename = N'sysadmin';" -QueryTimeout 3600 -ServerInstance $ServerName

    Invoke-Sqlcmd "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2" -QueryTimeout 3600 -ServerInstance $ServerName

    Restart-Service -Force MSSQLSERVER
    #In case restart failed but service was shut down.
    Start-Service -Name 'MSSQLSERVER' 
}

Setup-Sql


$env:chocolateyUseWindowsCompression = 'true'
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose
choco feature enable -n allowGlobalConfirmation
choco install dotnetfx -y -force
choco install sql-server-management-studio -y -force
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Microsoft SQL Server Management Studio 18.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
$Shortcut.Save()

sleep 5

(New-Object System.Net.WebClient).DownloadFile('https://aka.ms/ssmsfullsetup', 'C:\SSMS-Setup.exe')
$pathArgs = {C:\SSMS-Setup.exe /Install /Quiet /Norestart }
Invoke-Command -ScriptBlock $pathArgs 

# Install dotnetcore 4.8
#Invoke-WebRequest 'https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe' -OutFile 'C:\ndp48-x86-x64-allos-enu.exe'
#$pathArgs = {C:\ndp48-x86-x64-allos-enu.exe /Install /Quiet /Norestart }
#Invoke-Command -ScriptBlock $pathArgs

#.Net 4.8
#$WebClient = New-Object System.Net.WebClient
#$WebClient.DownloadFile("https://go.microsoft.com/fwlink/?linkid=2088631","C:\ndp48-web.exe")
#Start-Process -file 'C:\ndp48-web.exe' -arg "/q /norestart /ACCEPTEULA=1"
sleep 20

#Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile 'C:\DataMigrationAssistant.msi'
Start-Process -file 'C:\DataMigrationAssistant.msi' -arg '/qn /l*v C:\dma_install.txt' -passthru | wait-process

Restart-Computer
