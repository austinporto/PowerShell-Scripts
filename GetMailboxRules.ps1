Connect-exchangeonline


Get-ExoMailbox -ResultSize Unlimited |
Select-Object -ExpandProperty rmclarty@power-pole.com |
ForEach-Object {Get-Inboxrule -Mailbox $_ |
Select-Object-Property MailboxOwnerID,Name,Enabled,From,Description,RedirectTo,ForwardTo