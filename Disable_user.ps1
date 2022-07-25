# NOTE: Open Powershell in Admin Mode. This will complete all task for the ON-PREM SERVER Side. 
# Make sure you run this where the ADSYnc Module is installed OR run a Delta sync on an AAD server.
#
# Prerequisite: OU called "Disabled Users"  


# How to use
# Adjust the $Username variable to the UPN of the desired user
# TODO: Use user input or CSV
$Username = "<Replace with Username>"
$ArchiveUPN = (get-ADuser -identity "$Username" -Properties *).name

# Rename user name to <UPN (Archive)> in AD
$NewDisplayName = "$ArchiveUPN (Archive)"

# Backup user groups to csv file
$BackupFile = 'UserGroupBackup-' + "$Username"  + '.csv'
Get-ADPrincipalGroupMembership "$Username" | sort name | select name | Export-Csv -Path "C:\Temp\$BackupFile"

# Remove user groups
Get-ADPrincipalGroupMembership "$Username" | foreach {Remove-ADGroupMember $_ -Member "$Username" -Confirm:$False}

# Disable user account
Set-ADUser "$Username" -Enabled:$False -CannotChangePassword:$True
$DN = (get-ADuser -identity "$Username" -Properties *).DistinguishedName
Rename-ADObject "$DN" -NewName "$NewDisplayName"
Set-ADUser "$Username" -replace @{DisplayName=$NewDisplayName}

# Move to Diabled Users OU within AD
$DisOU = (Get-ADOrganizationalUnit -Filter 'Name -eq "Disabled Users"' -Properties *).DistinguishedName
Move-ADObject -Identity "$DN" -TargetPath "$DisOU" -Confirm:$False

# Remove user from 365 Addr Lists
Set-ADUser "$Username" -replace @{msExchHideFromAddressLists=$true}

Start-ADSyncSyncCycle -PolicyType Delta
