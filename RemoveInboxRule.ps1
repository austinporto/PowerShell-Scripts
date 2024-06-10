# BBE SCRIPT AUSTIN

# Check user for mailbox rules.

Connect-ExchangeOnline

$UPN = Read-Host "Enter UPN here"

# Get all mailbox rules

Get-InboxRule -Mailbox $UPN | Format-Table Name,Enabled

# Disable all mailbox rules

$Mailboxes = Get-Mailbox -ResultSize Unlimited
foreach ($Mailbox in $Mailboxes) {
    Get-InboxRule -Mailbox $Mailbox.UserPrincipalName | Disable-InboxRule -Confirm:$false
}





