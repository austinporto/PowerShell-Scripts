#BBE SCRIPT AUSTIN

# Use this to remove Outlook Web (OWA) from user profiles

Connect-ExchangeOnline 

Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    Set-CASMailbox -Identity $_.Identity -OWAEnabled $false

}

Disconnect-ExchangeOnline -Confirm:$false

