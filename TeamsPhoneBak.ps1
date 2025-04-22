Import-Module -Name .\BackAtTAC.psd1

# Create a backup folder with the current date
$BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null

# Backup all Teams Phone Admin Center data
BackUp-TACData -Path $BackUpFolder