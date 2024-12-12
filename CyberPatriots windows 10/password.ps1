# Ensure the script runs as an administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Please run this script as Administrator."
    exit
}

# Log file to record actions
$logFile = "C:\SetUserPasswordsLog.txt"
Write-Output "Setting all user passwords to P@s$w0r3! and disabling 'Password Never Expires'" | Out-File -Append $logFile

# New password
$newPassword = "P@s$w0r3!"

# Get all local users
$users = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -ne "Administrator" }

# Iterate through each user
foreach ($user in $users) {
    try {
        # Set the new password
        $user | Set-LocalUser -Password (ConvertTo-SecureString -String $newPassword -AsPlainText -Force)
        Write-Output "Password for user '$($user.Name)' set successfully." | Out-File -Append $logFile

        # Disable "Password Never Expires"
        $user | Set-LocalUser -PasswordNeverExpires $false
        Write-Output "Disabled 'Password Never Expires' for user '$($user.Name)'." | Out-File -Append $logFile
    } catch {
        Write-Output "Failed to update user '$($user.Name)': $_" | Out-File -Append $logFile
    }
}

Write-Output "Password update process complete. Check $logFile for details."
