# Connect to Exchange Online

Connect-ExchangeOnline

$listUsers = Read-Host "Would you a list of ALL users in the organization? (Y/N)"

if ($listUsers -eq 'Y') {
    Get-Mailbox -ResultSize Unlimited | Format-Table DisplayName, PrimarySmtpAddress
}

$UPN = Read-Host "Enter UPN here"

# Initialize an array to hold all groups
$allGroups = @()

# Get Distribution Group memberships
$DistributionGroups = Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | 
foreach {$_.PrimarySmtpAddress}) -contains "$UPN"}

# Add Distribution Groups to the allGroups array
foreach ($group in $DistributionGroups) {
    $obj = New-Object PSObject -Property @{
        GroupType           = "Distribution Group"
        DisplayName         = $group.DisplayName
        PrimarySmtpAddress  = $group.PrimarySmtpAddress
    }
    $allGroups += $obj
}

# Get Microsoft 365 Group memberships
$MS365Groups = Get-UnifiedGroup | where { (Get-UnifiedGroupLinks $_.Name -LinkType Members |
foreach {$_.PrimarySmtpAddress}) -contains "$UPN"}

# Add Microsoft 365 Groups to the allGroups array
foreach ($group in $MS365Groups) {
    $obj = New-Object PSObject -Property @{
        GroupType           = "Microsoft 365 Group"
        DisplayName         = $group.DisplayName
        PrimarySmtpAddress  = $group.PrimarySmtpAddress
    }
    $allGroups += $obj
}

# Display all groups
$index = 1
$allGroups | ForEach-Object {
    Write-Host "$index. $($_.GroupType): $($_.DisplayName) [$($_.PrimarySmtpAddress)]"
    $index++
}

# Prompt for group selection
$selectedGroupIndex = Read-Host "Enter the number of the group to remove the user from, or type 'All' to remove from all groups"

# Logic to remove user from all groups
if ($selectedGroupIndex -ieq "All") {
    $allGroups | ForEach-Object {
        if ($_.GroupType -eq "Distribution Group") {
            Remove-DistributionGroupMember -Identity $_.PrimarySmtpAddress -Member $UPN -Confirm:$false
        } elseif ($_.GroupType -eq "Microsoft 365 Group") {
            Remove-UnifiedGroupLinks -Identity $_.PrimarySmtpAddress -LinkType Members -Links $UPN -Confirm:$false
        }
        Write-Output "Removed user from group: $($_.DisplayName)"
    }
} else {
    $selectedGroup = $allGroups[$selectedGroupIndex - 1]
    if ($selectedGroup.GroupType -eq "Distribution Group") {
        Remove-DistributionGroupMember -Identity $selectedGroup.PrimarySmtpAddress -Member $UPN -Confirm:$false
    } elseif ($selectedGroup.GroupType -eq "Microsoft 365 Group") {
        Remove-UnifiedGroupLinks -Identity $selectedGroup.PrimarySmtpAddress -LinkType Members -Links $UPN -Confirm:$false
    }
    Write-Output "Removed user from group: $($selectedGroup.DisplayName)"
}

# Disconnect the Exchange Online session
Disconnect-ExchangeOnline -Confirm:$false

