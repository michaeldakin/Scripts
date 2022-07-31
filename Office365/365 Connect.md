# load the EXO V2 module

Import-Module ExchangeOnlineManagement

# Connect to O365 Admin account

Connect-ExchangeOnline -UserPrincipalName <>

# Get mailbox settings

Get-EXOMailbox <email> | fl message\*

# ...

Set-Mailbox <email> -MessageCopyForSendOnBehalfEnabled $true <ETC>

# Get specific mailbox proxy addresss

Get-EXORecipient -ResultSize unlimited | Where-Object {$\_.EmailAddresses -match "online@assetplant.com.au"} | Format-List Name, RecipientType, emailaddresses

# Get all mailboxes with certain domain

Get-EXORecipient -ResultSize unlimited | Where-Object {$\_.EmailAddresses -like "\*@luccidesign.com.au"} | Format-List Name, RecipientType, emailaddresses

# Disconnect session

Disconnect-ExchangeOnline
