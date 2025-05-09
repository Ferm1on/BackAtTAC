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

Import-Module BackAtTAC

#----------------------------------------------- BackUp-TACData ----------------------------------------------
# EXAMPLE 1
    # Create a backup folder with the current date
    $BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
    New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null

    # Backup all Teams Phone Admin Center data
    BackUp-TACData -Path $BackUpFolder

# EXAMPLE 2
    # Create a backup folder with the current date
    $BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
    New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null 

    # Backup All Teams Phone Admin Center data and write verbosity output to log file
    $LogFile = "TACLog_$((Get-Date).ToString('ddMM')).txt"
    $FullLogFile = ".\$BackUpFolder\$LogFile"
    BackUp-TACData -Path $BackUpFolder -Verbose 4>> $FullLogFile

# EXAMPLE 3
    # Create a backup folder with the current date and log file path
    $BackUpFolder = "TACBackUp_$((Get-Date).ToString('ddMM'))"
    New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
    $LogFile = "TACLog_$((Get-Date).ToString('ddMM')).txt"
    $FullLogFile = ".\$BackUpFolder\$LogFile"

    # Only backup select properties to CSV. and log verbosity to file
    $Properties = @(
    'Subnet',
    'Switch'
    )
    BackUp-TACData -Path $BackUpFolder -CSV -Properties $Properties -Verbose 4>> $FullLogFile

#----------------------------------------------- ReadTACData-TACData ----------------------------------------------
# dir .\TACBackUp_0405\

# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# la---            5/4/2025 12:33 PM           2402 Subnet_0405.csv
# la---            5/4/2025 12:33 PM           4327 Switch_0405.csv
# la---            5/4/2025 12:33 PM            175 TACLog_0405.txt

# EXAMPLE 1
    # Read Subnet file data into terminal from csv files
    $LoadedData = Read-TACData -Path ".\Subnet_0405.csv"
    $LoadedData

# EXAMPLE 2
    # Read Subnet file data into terminal from xml files
    $LoadedData = Read-TACData -Path ".\Subnet_0405.xml"
    $LoadedData

# EXAMPLE 3
    # Read Subnet file data into terminal from csv files with verbosity
    $LoadedData = Read-TACData -Path ".\Subnet_0405.csv" -Verbose
    $LoadedData

# EXAMPLE 4
    # Read file using checksum test
    $FileChecksum = Get-FileHash -Path ".\Subnet_0405.csv" -Algorithm SHA256
    $LoadedData = Read-TACData -Path ".\Subnet_0405.csv" -Checksum $FileChecksum.Hash
    $LoadedData

# Example 5 and 6 SETUP

# dir .\TACBackUp_0405\
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# la---            5/4/2025 12:44 PM          10778 CivicAddress_0405.csv
# la---            5/4/2025 12:44 PM          11318 LocationSchema_0405.csv
# la---            5/4/2025 12:44 PM           2402 Subnet_0405.csv
# la---            5/4/2025 12:44 PM           4327 Switch_0405.csv
# la---            5/4/2025 12:44 PM          17005 WaP_0405.csv

    
    $PathCSV = @(
        '.\CivicAddress_0405.csv',
        '.\LocationSchema_0405.csv',
        '.\Subnet_0405.csv',
        '.\Switch_0405.csv',
        '.\WaP_0405.csv'
    )

# EXAMPLE 5

    # Load all files in the directory into a variable
    $LoadedData = Read-TACData -Path $PathCSV

    # Each teams data can be accessed with $DataArray[i]
    Foreach ($DataArray in $LoadedData) {
        $DataArray
    }

# Example 6

    # Array to store file hashes
    $All_Hashes = [System.Collections.ArrayList]::new()

    # Build checksum array
    foreach ($File in $PathCSV) {
        $FileChecksum = Get-FileHash -Path $File -Algorithm SHA256
        $All_Hashes.Add($FileChecksum) | Out-Null
    }
    
    # Build only hash array
    $HashArray = @()
    
    foreach ($Hash in $All_Hashes) {
        $HashArray += $Hash.Hash
    }

    # Load all files in directory into a variable using checksum test.
    $LoadedData = Read-TACDAta -Path $PathCSV -Checksum $HashArray

    # Each teams data can be accessed with $DataArray[i]
    Foreach ($DataArray in $LoadedData) {
        $DataArray
    }
    
# EXAMPLE 7 SETUP

# dir .\TACBackUp_0405\
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# la---            5/4/2025 12:44 PM          17005 FooBar_0405.csv
# la---            5/4/2025 12:44 PM          10778 FooBar1_0405.csv
# la---            5/4/2025 12:44 PM          11318 FooBar2_0405.csv
# la---            5/4/2025 12:44 PM           2402 FooBar3_0405.csv
# la---            5/4/2025 12:44 PM           4327 FooBar4_0405.csv

# la---            5/4/2025 12:44 PM          17005 WaP_0405.csv

    $PathCSV = @(
        '.\FooBar1_0405.csv',
        '.\FooBar2_0405.csv',
        '.\FooBar3_0405.csv',
        '.\FooBar4_0405.csv',
        '.\FooBar5_0405.csv'
    )

    $Properties = @(
    'CivicAddress',
    'LocationSchema',
    'Subnet',
    'Switch',
    'WAP'
    )

# EXAMPLE 7

    # Load all files in the directory into a variable with non-standard names. 
    # files and properties array possition should corespond. i.e $Tuble = @($PathCSV[i], $Properties[i])
    $LoadedData = Read-TACData -Path $PathCSV -Properties $Properties

    # Each teams data can be accessed with $DataArray[i]
    Foreach ($DataArray in $LoadedData) {
        $DataArray
    }

# EXAMPLE 8
    # Load Port data from CSV in current directory and publish to Teams Admind Center
    $LoadedData = Read-TACData -Path .\Port_0805.csv
    Publish-TacProperty -Values $LoadedData -Property Port