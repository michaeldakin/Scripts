NOTE: Open Powershell in Admin Mode. This will complete all task for the ON-PREM SERVER Side. Make sure you run this where the ADSYnc Module is installed.

$Username = "<Replace with Username>"

$Temp1 = (get-ADuser -identity "$Username" -Properties *).name
$NewDisplayName = "$Temp1 (Archive)"
$BakFile = 'UserGroupBackup-' + "$Username"  + '.csv'
Get-ADPrincipalGroupMembership "$Username" | sort name | select name | Export-Csv -Path "C:\Evologic\$BakFile"
Get-ADPrincipalGroupMembership "$Username" | foreach {Remove-ADGroupMember $_ -Member "$Username" -Confirm:$False}
Set-ADUser "$Username" -Enabled:$False -CannotChangePassword:$True
$DN = (get-ADuser -identity "$Username" -Properties *).DistinguishedName
Rename-ADObject "$DN" -NewName "$NewDisplayName"
Set-ADUser "$Username" -replace @{DisplayName=$NewDisplayName}
$DisOU = (Get-ADOrganizationalUnit -Filter 'Name -eq "Disabled User Mailboxes"' -Properties *).DistinguishedName
Move-ADObject -Identity "$DN" -TargetPath "$DisOU" -Confirm:$False
Set-ADUser "$Username" -replace @{msExchHideFromAddressLists=$true}
Start-ADSyncSyncCycle -PolicyType Delta
