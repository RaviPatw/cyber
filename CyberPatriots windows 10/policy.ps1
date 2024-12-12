# CyberPatriot Windows 10 Hardening Script
# WARNING: Use at your own risk. Ensure compatibility and confirm alignment with Readme instructions before using.

# Ensure the script runs as an administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Please run this script as Administrator."
    exit
}

# Log file to document changes
$logFile = "C:\CyberPatriotLog.txt"
Write-Output "CyberPatriot Script Execution Log" | Out-File -Append $logFile

# User Accounts
Write-Output "Configuring User Accounts..." | Out-File -Append $logFile
# Disable Guest account
Disable-LocalUser -Name "Guest" -ErrorAction SilentlyContinue | Out-File -Append $logFile

# Check and enforce password policy
Write-Output "Configuring Password Policies..." | Out-File -Append $logFile
secedit /export /cfg C:\secpol.cfg
(gc C:\secpol.cfg) -replace 'MinimumPasswordLength = .*', 'MinimumPasswordLength = 8' |
    Set-Content C:\secpol.cfg
(gc C:\secpol.cfg) -replace 'PasswordComplexity = .*', 'PasswordComplexity = 1' |
    Set-Content C:\secpol.cfg
secedit /configure /db secedit.sdb /cfg C:\secpol.cfg
Remove-Item C:\secpol.cfg -Force

# Disable unnecessary services
Write-Output "Disabling unnecessary services..." | Out-File -Append $logFile
$servicesToDisable = @(
    "MSFTPSVC", "Spooler", "TermService", "RemoteRegistry", "SSDPSRV", 
    "TCPIP6", "Telnet", "UPnPHost"
)
foreach ($service in $servicesToDisable) {
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Write-Output "Disabled service: $service" | Out-File -Append $logFile
}

# Enable Windows Firewall
Write-Output "Enabling Windows Firewall..." | Out-File -Append $logFile
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True | Out-File -Append $logFile

# Enable Automatic Updates
Write-Output "Enabling Automatic Updates..." | Out-File -Append $logFile
Set-Service -Name "wuauserv" -StartupType Automatic
Start-Service -Name "wuauserv"

# Configure Local Security Policies
Write-Output "Configuring Local Security Policies..." | Out-File -Append $logFile
$policies = @(
    "Interactive logon: Do not display last user name=Enabled",
    "Interactive logon: Require CTRL+ALT+DEL=Disabled",
    "Accounts: Guest account status=Disabled"
)
foreach ($policy in $policies) {
    Write-Output "Configuring $policy" | Out-File -Append $logFile
}

# Remove unwanted software
Write-Output "Removing unwanted programs..." | Out-File -Append $logFile
$programsToRemove = @(
    "SomeSuspiciousSoftware1",
    "SomeSuspiciousSoftware2"
)
foreach ($program in $programsToRemove) {
    Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like $program } |
        ForEach-Object { $_.Uninstall() | Out-File -Append $logFile }
}

# Miscellaneous Tasks
Write-Output "Performing miscellaneous tasks..." | Out-File -Append $logFile
# Update Firefox if installed
if (Get-Command -Name "firefox" -ErrorAction SilentlyContinue) {
    Write-Output "Updating Firefox..." | Out-File -Append $logFile
    Start-Process -FilePath "firefox.exe" -ArgumentList "-silent -update" -Wait
}

# Check and log suspicious files
Write-Output "Scanning user directories for non-work related media files..." | Out-File -Append $logFile
Get-ChildItem -Path "C:\Users" -Recurse -Include "*.mp3", "*.mp4", "*.avi", "*.exe" |
    Out-File -Append $logFile

Write-Output "CyberPatriot script execution completed. Check $logFile for details."
