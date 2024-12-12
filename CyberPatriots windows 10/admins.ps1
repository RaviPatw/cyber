# Ensure the script runs as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Please run this script as Administrator."
    exit
}

# Log file to record actions
$logFile = "C:\ManageAdminUsersLog.txt"
Write-Output "Managing Administrator Group Membership..." | Out-File -Append $logFile

# Get the list of current administrators
$currentAdmins = (Get-LocalGroupMember -Group "Administrators").Where({ $_.ObjectClass -eq "User" }).Name
Write-Output "Current Administrators: $currentAdmins" | Out-File -Append $logFile

# Prompt for the list of authorized administrators
Write-Host "Enter the list of users who should be administrators (separate by spaces):"
$authorizedAdminsInput = Read-Host
$authorizedAdmins = $authorizedAdminsInput -split "\s+" # Split input by spaces into an array

# Process users in the Administrators group
foreach ($admin in $currentAdmins) {
    if ($authorizedAdmins -notcontains $admin) {
        try {
            # Remove unauthorized administrator
            Remove-LocalGroupMember -Group "Administrators" -Member $admin
            Write-Output "Removed '$admin' from Administrators group." | Out-File -Append $logFile
            
            # Ensure the user is in the Users group
            Add-LocalGroupMember -Group "Users" -Member $admin -ErrorAction SilentlyContinue
            Write-Output "Added '$admin' to Users group." | Out-File -Append $logFile
        } catch {
            Write-Output "Failed to demote '$admin': $_" | Out-File -Append $logFile
        }
    } else {
        Write-Output "User '$admin' is authorized as an administrator. No changes made." | Out-File -Append $logFile
    }
}

# Add missing authorized administrators
foreach ($authAdmin in $authorizedAdmins) {
    if ($currentAdmins -notcontains $authAdmin) {
        try {
            # Add missing authorized administrator
            Add-LocalGroupMember -Group "Administrators" -Member $authAdmin
            Write-Output "Added '$authAdmin' to Administrators group." | Out-File -Append $logFile
        } catch {
            Write-Output "Failed to promote '$authAdmin': $_" | Out-File -Append $logFile
        }
    }
}

Write-Output "Administrator group management complete. Check $logFile for details."
