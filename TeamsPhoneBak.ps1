<#
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2024 Michael Rodrigues da Cunha

BackAtTAC is a free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

BackAtTAC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

This scripts assumes BackAtTAC is not installed and the .psd1 and .psm1 files are simply in the same directory as the script.
#>

Import-Module -Name .\BackAtTAC.psd1

# Create a backup folder with the current date
$BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null

# Backup all Teams Phone Admin Center data
BackUp-TACData -Path $BackUpFolder
