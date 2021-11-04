param(
    [string]$resource_group,
    [string]$storage_account_name,
    [string]$filename_suffix
)
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resource_group -Name $storage_account_name
$repoUrl = 'https://github.com/tayganr/pvdata/archive/refs/heads/main.zip'
$containerName = "data"
$outFileName = "repo"
Invoke-RestMethod -Uri $repoUrl -OutFile "${outFileName}.zip"
Expand-Archive -Path "${outFileName}.zip"
Set-Location -Path "${outFileName}\pvdata-main\assets"
Get-ChildItem -File -Recurse | Rename-Item -NewName {"${filename_suffix}_$($_.BaseName)$($_.Extension)"}
Get-ChildItem -File -Recurse | Set-AzStorageBlobContent -Container ${containerName} -Context $storageAccount.Context