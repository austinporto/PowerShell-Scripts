# Prompt user to enter folder path
$folderPath = Read-Host "Enter folder path"

# Check if folder path exists
if (Test-Path $folderPath -PathType Container) {
    # Get ACL (Access Control List) for the folder
    $acl = Get-Acl $folderPath

    # Extract folder name from the folder path
    $folderName = (Get-Item $folderPath).Name

    # Extract access rules for each user or group
    $accessList = $acl.Access | Select-Object IdentityReference

    # Get desktop folder path for current user
    $desktopPath = [Environment]::GetFolderPath("Desktop")

    # Define output file path with folder name
    $outputFile = Join-Path -Path $desktopPath -ChildPath "$folderName Access.txt"

    # Write access list to text file
    $accessList | Out-File -FilePath $outputFile

    Write-Host "Access list has been written to $outputFile"
} else {
    Write-Host "Folder path not found."
}
