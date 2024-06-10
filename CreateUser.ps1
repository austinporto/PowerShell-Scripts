#BBE SCRIPT AUSTIN

#Create new user and assign user groups MS365

# Connect to Azure AD
Connect-AzureAD

$createUser = Read-Host "Would you like to create a new user? Y for Yes, N for No"
if ($createUser -eq 'Y') {
    # Ask for user details
    $firstName = Read-Host "Enter the user's first name"
    $lastName = Read-Host "Enter the user's last name"
    $displayName = "$firstName $lastName"
    Write-Host "Display Name: $displayName"
    $License = Read-Host "Enter license number (e.g., 1 for Business Essentials)"
    
    $licenseSKU = $null
    if ($License -eq "1") {
        $licenseSKU = "O365_BUSINESS_ESSENTIALS" # Placeholder, replace with actual SKU
    }

    $userPrincipalName = Read-Host "Enter the user's email (user@domain.com)"
    $password = Read-Host "Enter the user's initial password" -AsSecureString

    # Create the new Azure AD user
    $newUser = New-AzureADUser -AccountEnabled $true -DisplayName $displayName -PasswordProfile (New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile -ArgumentList @{"Password"=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)); "ForceChangePasswordNextSignIn"=$true}) -UserPrincipalName $userPrincipalName -MailNickName ($firstName + $lastName)

    if ($licenseSKU) {
        # Find the SKU ID for the license
        $licenses = Get-AzureADSubscribedSku
        $selectedLicense = $licenses | Where-Object { $_.SkuPartNumber -eq $licenseSKU }
        
        if ($selectedLicense) {
            $licenseToAdd = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
            $licenseToAdd.SkuId = $selectedLicense.SkuId
            $licenseToAdd.DisabledPlans = @()
            
            $licensesToAssign = New-Object Microsoft.Open.AzureAD.Model.AssignedLicenses
            $licensesToAssign.AddLicenses = @($licenseToAdd)
            $licensesToAssign.RemoveLicenses = @()
            
            # Assign the license
            try {
                Set-AzureADUserLicense -ObjectId $newUser.ObjectId -AssignedLicenses $licensesToAssign
            } catch {
                Write-Error "Failed to assign license: $_"
            }
        } else {
            Write-Host "License SKU not found or not available."
        }
    }
}



# Disconnect from Azure AD
Disconnect-AzureAD
