# This scripts assumes BackAtTAC is not installed and the .psd1 and .psm1 files are simply in the same directory as the script.
Import-Module -Name .\BackAtTAC.psd1

# Create a backup folder with the current date
$BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null

# Backup all Teams Phone Admin Center data
BackUp-TACData -Path $BackUpFolder
