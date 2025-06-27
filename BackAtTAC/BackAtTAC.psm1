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

To Load this module do
Import-Module .\BackAtTAC.psd1
Get-Help BackUp-TACData -Full (or Read-TACData, Reset-TACProperty, Publish-TACProperty))
To unload Module do
Remove-Module BackAtTAC
To List Modules do
Get-Module
Dependencies: MicrosoftTeams 6.9.0, Powershell 7.5 or higher for -Fast option.
To install Dependencies do:
Install-Module -Name PowerShellGet -Force -AllowClobber
Install-Module -Name MicrosoftTeams -Force -AllowClobber
#>

#---------------------------------------- PRIVATE FUNCTION DEFINITIONS ----------------------------------------

# Write a file to the specified path. The file name is generated dynamically based on the property type and current date.
function Write-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,

        [Parameter(Mandatory=$true)]
        [System.Object]$Property,

        [Parameter(Mandatory=$false)]
        [switch]$CSV=$false,

        [Parameter(Mandatory=$false)]
        [switch]$XML=$false,

        [Parameter(Mandatory=$false)]
        [switch]$Fast=$false
    )

    #------------------------------------------ ERROR CHECKING START ------------------------------------------
    if (-not $Property -or $Property.Count -eq 0) {
        Write-Warning "Write-File: The provided object is null or empty, skipping export."
        Write-Verbose "Write-File: The provided object is null or empty, skipping export."
        return
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------

    # Generate FileName dynamically
    # Extract the type name after the last period
    $FullTypeName = ($Property | Select-Object -First 1).GetType().FullName
    if ($FullTypeName -match '([^\.]+)$') {
        $CapturedName = $Matches[1] -replace 'Response$', ''
    } else {
        $CapturedName = "ExportedData"
    }

    $FileName = "${CapturedName}_$((Get-Date).ToString('ddMM'))"
    
    $FullFilePath = Join-Path -Path $FolderPath -ChildPath $FileName

    try {
        # Export the object to CSV and XML
        if ($CSV -eq $XML) {
            # In Parallel
            if ($Fast) {
                $Jobs = @(
                    Start-ThreadJob -ScriptBlock { param($Property, $Path) $Property | Export-Csv -Path "$Path.csv" -NoTypeInformation -Force } -ArgumentList $Property, $FullFilePath
                    Start-ThreadJob -ScriptBlock { param($Property, $Path) $Property | Export-Clixml -Path "$Path.xml" -Force } -ArgumentList $Property, $FullFilePath
                )
                $Jobs | Wait-Job | Receive-Job
                $Jobs | Remove-Job
                Write-Verbose "Exported '$FullFilePath.csv' and '$FullFilePath.xml' successfully -Fast"

            } else {
                # Sequential 
                $Property | Export-Csv -Path "$FullFilePath.csv" -NoTypeInformation -Force
                $Property | Export-Clixml -Path "$FullFilePath.xml" -Force
                Write-Verbose "Exported '$FullFilePath.csv' and '$FullFilePath.xml' successfully"
            }
        }
        elseif ($CSV) {
            # Export the object to CSV
            $Property | Export-Csv -Path "$FullFilePath.csv" -NoTypeInformation -Force
            Write-Verbose "Exported '$FullFilePath.csv' successfully"
        } elseif ($XML) {
            # Export the object to XML
            $Property | Export-Clixml -Path "$FullFilePath.xml" -Force
             Write-Verbose "Exported '$FullFilePath.xml' successfully"
        } 
        return

    } catch {
        Write-Error "Could not export '$FullFilePath': $_"
        return
    }
}
$Write_File = [ScriptBlock]::Create((Get-Command Write-File -CommandType Function).Definition)

# Reads backup file with integrity checking. 
# This fuction checks if the file is a CSV or XML file, and that the file schema matches the MicrosoftTeams 7.0.0 scheme.
# Optionally, you can pass a SHA256 checksum to validate the file integrity further.
function Read-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Property,

        [Parameter(Mandatory=$false)]
        [string]$Checksum
    )

    #$callerVerbose = (Get-Variable -Name VerbosePreference -Scope 0).Value
    #Write-Host "Verbose Setting: $callerVerbose"

    #------------------------------------------ BASIC ERROR CHECKING START ------------------------------------------

    # Check if the path is valid
    if (-not (Test-Path -Path $Path)) {
        Write-Error "Read-CsvFile: CSV file not found at path: '$Path'"
        return
    }

    # If provided, check if checksum matches.
    if ($Checksum) {
        if ((Get-FileHash -Path $Path -Algorithm SHA256).Hash -eq $Checksum) {
            Write-Verbose "File checksum integrity for '$Path' passed."
        } else {
            Write-Error "File integrity check failed for '$Path'. File may be corrupted or wrong file input."
            return
        }
    }
    #------------------------------------------- BASIC ERROR CHECKING END -------------------------------------------

    if ($Path -match '\.(csv)$') {
        # Importing CSV file
        try {
            # Load the CSV
            $CsvObject = Import-Csv -Path $Path
            $AllKeys = @()
        
            # Check existence and non-null for each column in CSV schema
            foreach ($tuple in $All_Properties_Parameters[$Property]) {
                $colName    = $tuple.Item1
                $isRequired = $tuple.Item2
                $isKey      = $tuple.Item3
        
                # Check Column existence
                if (-not ($CsvObject[0].PSObject.Properties.Name -contains $colName)) {
                    if ($isRequired) {
                        Write-Error "'$colName' column is required, CSV not loaded"
                        return
                    }
                    else {
                        Write-Verbose "'$colName' does not exist"
                        continue
                    }
                }
                
        
                # Column is present, if it's required, ensure no row is empty/null
                if ($isRequired) {

                    # build a list of zero-based indices where the value is null or whitespace <-- NEEDS TESTING
                    $badIndices = 0..($CsvObject.Count - 1) |
                        Where-Object {[string]::IsNullOrWhiteSpace($CsvObject[$_].$colName)}
        
                    if ($badIndices) {
                        # adjust to human-friendly line numbers (+2 because header is line 1) <-- NEEDS TESTING
                        $badLines = $badIndices | ForEach-Object { $_ + 2 }
                        Write-Error "Required column '$colName' on '$Path' has empty values at CSV line(s): $($badLines -join ', ')"
                        return
                    }
                    
                    Write-Verbose "Required Column '$colName' on '$Path' exists and it's fully populated"
                }

                # Collect all key values
                if($IsKey){
                    $AllKeys += $ColName
                }
            }

            # Check for duplicate key values
            if ($AllKeys) {
                # Group rows by the combination of all key columns
                $duplicateGroups = $CsvObject |
                    Group-Object -Property $AllKeys |
                    Where-Object { $_.Count -gt 1 }
            
                if ($duplicateGroups) {
                    foreach ($grp in $duplicateGroups) {
                        # compute human-readable line numbers (+2 for header + zero-index)
                        $lineNumbers = $grp.Group |
                            ForEach-Object { [array]::IndexOf($CsvObject, $_) + 2 }
            
                        # build a “Key1=val1, Key2=val2” summary of the duplicate combo
                        $combo = (
                            $AllKeys |
                            ForEach-Object { "$_=$($grp.Group[0].$_)" }
                        ) -join ', '
            
                        Write-Error "Duplicate key combination ($combo) found at CSV line(s): $($lineNumbers -join ', ')"
                    }
                    return
                }
                Write-Verbose "Duplicate key check passed for '$Path'"
            }

            # Check for non-standard attribute in loaded file
            $nonStandardAttributes = $CsvObject[0].PSObject.Properties.Name | Where-Object { $All_Properties_Parameters[$Property].Item1 -notcontains $_ }
            if ($nonStandardAttributes) {
                Write-Verbose "Non-standard attributes found in CSV file: $($nonStandardAttributes -join ', ')"
            }

            Write-Verbose "CSV file: '$Path' passed attribute integrity check."
            Write-Verbose "Imported '$Path' to enviroment."
            return $CsvObject
        }
        catch { 
            Write-Error "Failed to import CSV file: $_"
            return
        }

    } elseif ($Path -match '\.(xml)$'){
        try {
            $XmlObject = Import-Clixml -Path $Path
            $AllKeys = @()

            # Check existence and non-null for each column in XML schema
            foreach ($tuple in $All_Properties_Parameters[$Property]) {
                $colName    = $tuple.Item1
                $isRequired = $tuple.Item2
                $isKey      = $tuple.Item3

                # existence against first node
                if (-not ($XmlObject[0].PSObject.Properties.Name -contains $colName)) {
                    if ($isRequired) {
                        Write-Error "$colName property is required, XML not loaded"
                        return
                    }
                    else {
                        Write-Verbose "$colName does not exist in XML"
                        continue
                    }
                }

                # non-null check across all nodes
                if ($isRequired) {
                    $badIndices = 0..($XmlObject.Count - 1) |
                        Where-Object { [string]::IsNullOrWhiteSpace( $XmlObject[$_].$colName ) }

                    if ($badIndices) {
                        $badLines = $badIndices | ForEach-Object { $_ + 1 } 
                        # +1 because XML elements don’t have a header line; adjust as you see fit
                        Write-Error "Required property '$colName' is empty in XML element indices: $($badLines -join ', ')"
                        return
                    }
                    Write-Verbose "Required Column '$colName' on '$Path' exists and it's fully populated."
                }

                # Collect all key values
                if($IsKey){
                    $AllKeys += $ColName
                }
            }

            if ($AllKeys) {
                # Group rows by the combination of all key columns
                $duplicateGroups = $XmlObject |
                    Group-Object -Property $AllKeys |
                    Where-Object { $_.Count -gt 1 }
            
                if ($duplicateGroups) {
                    foreach ($grp in $duplicateGroups) {
                        # compute human-readable line numbers (+2 for header + zero-index)
                        $lineNumbers = $grp.Group |
                            ForEach-Object { [array]::IndexOf($XmlObject, $_) }
            
                        # build a “Key1=val1, Key2=val2” summary of the duplicate combo
                        $combo = (
                            $AllKeys |
                            ForEach-Object { "$_=$($grp.Group[0].$_)" }
                        ) -join ', '
            
                        Write-Error "Duplicate key combination ($combo) found at Xml RefId: $($lineNumbers -join ', ')"
                    }
                    return
                }
                Write-Verbose "Duplicate key check passed for '$Path'"
            }

            # Check for non-standard attribute in loaded file
            $nonStandardAttributes = $XmlObject[0].PSObject.Properties.Name | Where-Object { $All_Properties_Parameters[$Property].Item1 -notcontains $_ }
            if ($nonStandardAttributes) {
                Write-Verbose "Non-standard attributes found in XML file: $($nonStandardAttributes -join ', ')"
            }            
            
            Write-Verbose "XML file: $Path passed attribute integrity check."
            Write-Verbose "Imported XML: $Path"
            return $XmlObject
        }
        catch { 
            Write-Error "Failed to import XML file: $_"
            return
        }

    } else {
        Write-Error "Unsupported file format. Only CSV and XML files are supported."
        return
    }
}
$Read_File = [ScriptBlock]::Create((Get-Command Read-File -CommandType Function).Definition)

# Function that errases all objects for a particular Property in the Teams Admin Center.
function Reset-Property {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact        = 'High'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Property,

        [Parameter(Mandatory = $false)]
        [switch]$Unsafe
    )

    #------------------------------------------ ERROR CHECKING START ------------------------------------------

    # Error checking for $Properties: Checking all user submited properties are supported
    if (-not $All_Properties_Functions.ContainsKey($Property)) {
        Write-Error "This module does not support the cloud erasure of '$Property' property."
        return
    }

    #------------------------------------------- ERROR CHECKING END -------------------------------------------

    #--------------------------------------------- VARIABLES START --------------------------------------------

    # Build remove call function and parameters
    $Remove = $All_Properties_Functions[$Property].Item2
    $Arguments = @()
    foreach ($tuple in $All_Properties_Parameters[$Property]) {
        if ($tuple.Item3) {
            $Arguments += $tuple.Item1
        }
    }

    # Download property from TAC and exit if empty.
    $PropertyToErase = $All_Properties_Functions[$Property].item1.Invoke()
    $DeletedImtes = @()
    if (-not $PropertyToErase) {
        Write-Verbose "No values found for property '$Property', skiping deletion."
        return
      }
    
    #--------------------------------------------- VARIABLES END ----------------------------------------------

    if (-not $Unsafe) {
        
        # Create a log file with the name of the property and the date
        try {
            $LogFile = "$($Property)_ResetLog_$((Get-Date).ToString('ddMM')).txt"
            New-Item -Path $LogFile -ItemType File | Out-Null
            
            # Output full path of the log file if verbose is enabled
            if ($VerbosePreference -eq 'Continue') {
                $LogFileFullPath = Join-Path -Path (Get-Location) -ChildPath $LogFile
                Write-Verbose "Log file created: $LogFileFullPath"
            }
        } catch {
            Write-Error "Failed to create log file: $_ file might already exists"
            return
        }
        
        foreach($Item in $PropertyToErase){

            if ($PSCmdlet.ShouldProcess("$Property Property on Teams Admin Center", "Delete $($Arguments[0]) $($Item.$($Arguments[0]))")) {
                
                # Build parameters
                $param = @{}
                foreach ($name in $Arguments) {$param[$name] = $Item.$name}

                # Log the item to be removed
                Add-Content -Path $LogFile -Value ($Item | Out-String)

                # Remove item
                & $Remove @param

                # add to deleted array
                $DeletedImtes += $Item
            }
        }

            Write-Verbose "Property $Property has been reset from Teams Admin Center. All values have been removed."
            return $DeletedImtes

    } else {
        
        foreach($Item in $PropertyToErase){

            if ($PSCmdlet.ShouldProcess("$Property Property on Teams Admin Center", "Delete $($Arguments[0]) $($Item.$($Arguments[0]))")) {
                
                # Build parameters
                $param = @{}
                foreach ($name in $Arguments) {$param[$name] = $Item.$name}

                # Remove item
                & $Remove @param

                # add to deleted array
                $DeletedImtes += $Item
            }
        }

        Write-Verbose "Property $Property has been reset from Teams Admin Center. All values have been removed."
        return $DeletedImtes  
    }
}

function Publish-Property {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Property
    )

    #------------------------------------------ BASIC ERROR CHECKING START ------------------------------------------ 
    # 1. Verify the property is supported for upload
    if (-not $All_Properties_Functions.ContainsKey($Property)) {
        Write-Error "This module does not support the cloud upload of '$Property' property."
        return
    }
    # 2. If no values provided, skip processing
    if (-not $Values -or $Values.Count -eq 0) {
        Write-Verbose "No values provided for property '$Property'; skipping upload."
        return
    }
    #------------------------------------------ BASIC ERROR CHECKING END ------------------------------------------ 

    #------------------------------------------------ VARIABLES START ---------------------------------------------
    
    # Build function call parameters and get upload function
    $Upload = $All_Properties_Functions[$Property].Item3
    $Arguments = @()
    # Create Item array to track uploaded items.
    $UploadedItems = @()
    # Create array to track keys
    $AllKeys = @()
    
    #------------------------------------------------ VARIABLES END -----------------------------------------------

    #------------------------------------------ ADVANCE ERROR CHECKING START --------------------------------------

    foreach ($tuple in $All_Properties_Parameters[$Property]) {
        $colName    = $tuple.Item1
        $isRequired = $tuple.Item2
        $isKey      = $tuple.Item3
        $isArgument = $tuple.Item4

        # Check Column existence
        if (-not ($Values[0].PSObject.Properties.Name -contains $colName)) {
            if ($isRequired) {
                Write-Error "'$colName' column is required, cannot upload."
                return
            }
            else {
                Write-Verbose "'$colName' does not exist"
                continue
            }
        }
        
        # Column is present, if it's required, ensure no row is empty/null
        if ($isRequired) {

            # build a list of zero-based indices where the value is null or whitespace <-- NEEDS TESTING
            $badIndices = 0..($Values.Count - 1) |
                Where-Object {[string]::IsNullOrWhiteSpace($Values[$_].$colName)}

            if ($badIndices) {
                # adjust to human-friendly line numbers (+2 because header is line 1) <-- NEEDS TESTING
                $badLines = $badIndices | ForEach-Object { $_ + 1 }
                Write-Error "Required column '$colName' has empty values at index: $($badLines -join ', ')"
                return
            }
            
            Write-Verbose "Required Column '$colName' exists and it's fully populated"
        }

        # Collect all key values
        if($isKey){
            $AllKeys += $colName
        }

        # Build Arguments array
        if($isArgument){
            $Arguments += $colName
        }
    }

    # Check keys
    if ($AllKeys) {
        # Group rows by the combination of all key columns
        $duplicateGroups = $Values |
            Group-Object -Property $AllKeys |
            Where-Object { $_.Count -gt 1 }
    
        if ($duplicateGroups) {
            foreach ($grp in $duplicateGroups) {
                # compute human-readable line numbers (+2 for header + zero-index)
                $lineNumbers = $grp.Group |
                    ForEach-Object { [array]::IndexOf($Values, $_) }
    
                # build a “Key1=val1, Key2=val2” summary of the duplicate combo
                $combo = (
                    $AllKeys |
                    ForEach-Object { "$_=$($grp.Group[0].$_)" }
                ) -join ', '
    
                Write-Error "Duplicate key combination ($combo) found at index: $($lineNumbers -join ', ')"
            }
            return
        }
        Write-Verbose "Duplicate key check passed for '$Property' property."
    }

    #------------------------------------------ ADVANCE ERROR CHECKING START -------------------------------------- 

    # upload each value to Teams Admin Center
    foreach($item in $Values){

        if ($PSCmdlet.ShouldProcess("$Property property on Teams Admin Center", "Upload $($Arguments[0]) $($item.$($Arguments[0]))")) {
            
            # Build parameters
            $param = @{}
            foreach ($name in $Arguments) {$param[$name] = $item.$name}

            # Upload item to TAC
            & $Upload @param

            # add to Uploaded array
            $UploadedItems += $item
        }
    }

    Write-Verbose "Property $Property has been uploaded to Teams Admin Center. All values have been added."
    return $UploadedItems
}

#---------------------------------------- PUBLIC FUNCTION DEFINITIONS -----------------------------------------

# Backs up Teams Admin Center data.
function BackUp-TACData {
    <#
    .SYNOPSIS
        Backs up Teams Admin Center data through 'MicrosoftTeams' PowerShell Module.
    
    .DESCRIPTION
        Backs up property data from Microsoft Teams Admin Center (e.g., CivicAddress, LocationSchema, Subnet, Switch, Port and WaP).
        Allows optional multithreading for faster (default is slow) export, uses switch for CSV/XML export preferences,
        and can optionally filter which properties are backed up. 
        Default: All properties are backed up and exported in both CSV and XML formats overwriting existing files with the same name. 
        Default file name for backups are '<Property>_DDMM.csv' and '<Property>_DDMM.xml'.
        To get this menu use Get-Help BackUp-TACData -Full
    
    .PARAMETER Path (Mandatory)
        The target directory to store exported backup files.

    .PARAMETER Properties (Optional)
        An array of Teams Admin Center property names to export (e.g., 'CivicAddress', 'LocationSchema'). If omitted, all properties are exported.
        Currently supported properties: 'CivicAddress', 'LocationSchema', 'Subnet', 'Switch', 'Port', 'WaP'.

    .PARAMETER CSV (Optional)
        Export only in CSV format. if both CSV and XML are selected, both formats will be exported.

    .PARAMETER XML (Optional)
        Export only in XML format. if both CSV and XML are selected, both formats will be exported.

    .PARAMETER Fast (Optional)
        Uses multithreading to save multiple files in parallel. Default is $NULL
        Fast option is only available in PowerShell 7.5 or higher.
        Fast option will be slow for small tenants, as the overhead of creating threads is greater than the time saved by parallel processing.

    .INPUTS
        System.String (Path)
        System.String[] (Properties)
        System.String (FileName)
        System.Boolean (CSV)
        System.Boolean (XML)
        System.Boolean (Fast)

    .OUTPUTS
        System.Boolean (Success = $Null / Failure = $False)  

    .EXAMPLE
        BackUp-TACData -Path "C:\\TACBackup"
        Backs up all properties, using sequential processing and exporting in both CSV and XML formats. File names are in the format '<Property>_DDMM.csv' and '<Property>_DDMM.xml'.
        
    .EXAMPLE
        BackUp-TACData -Path "C:\\TACBackup" -Properties "CivicAddress","LocationSchema" -CSV -Fast 
        Backs up CivicAddress and LocationSchema as CSV, using multithreading (Fast).

    .LINK
        https://github.com/Ferm1on/Teams-Powershell-Backup-Module

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [string[]]$Properties,

        [Parameter(Mandatory=$false)]
        [switch]$CSV=$false,

        [Parameter(Mandatory=$false)]
        [switch]$XML=$false,

        [Parameter(Mandatory=$false)]
        [switch]$Fast=$false
    )

    #------------------------------------------ ERROR CHECKING START ------------------------------------------
    # Error checking for $FolderPath: Checking if path exists
    if (-not (Test-Path -Path $Path)) {
        Write-Error "Invalid Path: $Path"
        return
    }

    # Error checking for $Properties: Checking all user submited properties are supported
    foreach ($Property in $Properties) {
        if (-not $All_Properties_Exporters.ContainsKey($Property)) {
            Write-Error "This module does not support the backup of '$Property' property."
            return
        }
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------
    Write-Verbose "Backing up properties"
    try {
        # Backing Up All Properties
        # Fast Option, Backup all properties in parallel. If not selected, backup properties sequentially.
        if($Fast) {
            $jobs = @()

            $FastVerbose = $PSBoundParameters.ContainsKey('Verbose')

            # Backup all properties else Backup selected properties.
            if(-not $Properties -or $Properties.Count -eq 0) {
                
                foreach ($Property in $All_Properties_Exporters.Values) {
                    $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast, $FastVerbose
                }
      
            } else {
                
                foreach ($Property in $Properties) {
                    $Jobs += Start-ThreadJob -ThrottleLimit $ThrottleLimit  -ScriptBlock $All_Properties_Exporters.($Property) -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast, $FastVerbose
                }
            }
              
            # Clean up jobs.
            $Jobs | Wait-Job | Receive-Job
            $jobs | Remove-Job
      
          } else {
              # Sequential processing of the functions
              # Backup all properties else Backup selected properties.
              if(-not $Properties -or $Properties.Count -eq 0) {
      
                  foreach ($Property in $All_Properties_Exporters.Values) {
                      & $Property -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast -FastVerbose:$PSBoundParameters.ContainsKey('Verbose')
                  }
                  
              } else {
                  foreach ($Property in $Properties) {
                      & $All_Properties_Exporters.($Property) -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast -FastVerbose:$PSBoundParameters.ContainsKey('Verbose')
                  }
              }
          }
          
          Write-Verbose "All properties backed up successfully."
          return

    } catch {
        Write-Error "Failed to backup data from TAC: $_"
        return
    }
    
}

# Reads an CSV or XML file and return a System.Object
function Read-TACData {
    <#
    .SYNOPSIS
        Reads a CSV or XML file and returns the content as a System.Object.

    .DESCRIPTION
        Reads a CSV/XML file using Import-Csv/Import-CliXml and returns a System.Object.
        This function checks the integrety of the backup file by checking if file schema matches MicrosoftTeams 6.9.0 scheme
        and that all required columns are present and not null as well as the presence of duplicate keys (Including composite keys)
        Optionally, you pay pass a SHA256 checksum to validate the file integrity further.

        To get this menu use Get-Help Reset-TACProperty -Full
        To get list of all functions do: Get-Command -Module BackAtTAC -CommandType Function

    .PARAMETER Path (Mandatory)
        The full file path to the backup file to import.
    
    .PARAMETER Properties (Optional)
        The type of property to import (e.g., CivicAddress, LocationSchema, Switch, Port, WaP).
    
    .PARAMETER Checksum (Optional)
        The SHA256 checksum of the backup file to validate its integrity.
    
    .INPUTS
        System.String[] (Path)
        System.String[] (Properties)
        System.String[] (Checksum)

    .OUTPUTS
        System.Object[] (Backup data)

    .EXAMPLE
        $csvData = Read-TACData -Path "C:\Path\to\<yourfile.csv>" -Properties "CivicAddress" -Checksum "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        Import data from the specified file into $csvData.

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Path,

        [Parameter(Mandatory=$false)]
        [string[]]$Properties,

        [Parameter(Mandatory=$false)]
         [string[]]$Checksum
    )

    # Variable Definitions
    $Backup_Files = [System.Collections.ArrayList]::new()

    #------------------------------------------ ERROR CHECKING START ------------------------------------------
    # Build Properties Array based on file names, if file name is non standard throw an error.
    if (-not $Properties) {
        $Properties = @()
    
        foreach ($file in $Path) {
            try {
                # strip path + extension, then grab everything before the first “_”
                $baseName = [IO.Path]::GetFileNameWithoutExtension($file)
                $key      = $baseName.Split('_')[0]
    
                # if it’s not one of the allowed keys, throw
                if (-not $All_Properties_Parameters.ContainsKey($key)) {
                    Write-Error "Invalid property '$key' in file '$file'. Allowed properties are: $($All_Properties_Parameters.Keys -join ', ')"
                    return
                }
    
                # use the canonical key from the hashtable (preserves your exact casing)
                $canonical = (
                    $All_Properties_Parameters.GetEnumerator() |
                    Where-Object { $_.Key -ieq $key }
                  ).Key
    
                $Properties += $canonical
            }
            catch {
                Write-Error $_
                return
            }
        }
        Write-Verbose "Properties array built from file names: $($Properties -join ', ')"
    } else {
         # Check $Properties Array size against $Path array size.
        if (-Not ($Path.Count -eq $Properties.Count)){
            Write-Error "Properties array not the same length as Path array"
            return
        }
        
        # Test if provided Properties are valid find any entries that aren’t valid keys
        $invalid = $Properties | Where-Object { -not $All_Properties_Parameters.ContainsKey($_) }
    
        if ($invalid) {
            Write-Error "Invalid property key(s): $($invalid -join ', '). `nAllowed properties are: $($All_Properties_Parameters.Keys -join ', ')"
            return
        }
    }

    # Check $Checksum Array size against $Path array size if provided
    if($checksum){
        if (-Not ($Path.Count -eq $Checksum.Count)){
            Write-Error "Checksum array not the same length as Path array"
            return
        }

        # Check if any $Checksum elements are null
        $bad = $Checksum | Where-Object { [string]::IsNullOrWhiteSpace($_) }
        if ($bad) {
            Write-Error "Checksum array contains null or empty value(s): $($bad -join ', ')"
            return
        }
        Write-Verbose "Checksum Array Check: Checksum array same length as Path array and no null values found."
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------
    
    if($Checksum){
        # If checksum is provided, call function with checksum.
        for ($i = 0; $i -lt $Path.Count; $i++) {
            $File     = $Path[$i]
            $Property = $Properties[$i]
            $Hash = $Checksum[$i]
        
            try {
                $data = Read-File -Path $File -Property $Property -Checksum $Hash -Verbose:$PSBoundParameters.ContainsKey('Verbose')
                $Backup_Files.Add($data) | Out-Null
            }
            catch {
                Write-Error "Failed to import CSV file: $_"
                return
            }
        }
    } else {
        for ($i = 0; $i -lt $Path.Count; $i++) {
            $File     = $Path[$i]
            $Property = $Properties[$i]
        
            try {
                $data = Read-File -Path $File -Property $Property -Verbose:$PSBoundParameters.ContainsKey('Verbose')
                $Backup_Files.Add($data) | Out-Null
            }
            catch {
                Write-Error "Failed to import file: $_"
                return
            }
        }
    }
    # Return array of imported data
    Write-Verbose "Imported $($Backup_Files.Count) files."
    return $Backup_Files
}

# Function wrapper for future expension and use. eventually could use -Fast switch, or reset multiple properties at once
function Reset-TACProperty {
        <#
    .SYNOPSIS
        Erases all objects for a particular Property in Teams Admin Center.

    .DESCRIPTION
        This function erases all objects for a particular Property in Teams Admin Center (e.g., CivicAddress, LocationSchema, Subnet, Switch, Port and WaP).
        It uses the MicrosoftTeams PowerShell Module to perform the operation.
        By default the function will log deleted objects to a file. log file name is '<Property>_ResetLog_DDMM.txt'.
        This is a high impact function, therefore comfirmation is on by default. to turn of confirmation do -Confirm:$false.

        To get this menu use Get-Help Reset-TACProperty -Full
        To get list of all functions do: Get-Command -Module BackAtTAC -CommandType Function
    
    .PARAMETER Property (Mandatory)
        The type of property to whipe (e.g., CivicAddress, LocationSchema, Switch, Port, WaP).

    .PARAMETER Unsafe (Optional)
        If this switch is used, the function will not log to file while deleting the property objects.
        By default the function will log deleted objects to a file. log file name is '<Property>_ResetLog_DDMM.txt'.
        This is done to keep track of deleted objects in case of a mistake or power loss.
    
    .INPUTS
        System.String[] (Property)
        System.Switch[] (Unsafe)
    
    .OUTPUTS
        System.Object[] (Deleted objects collection)

    .EXAMPLE
        Reset-TACProperty -Property "Port" -Unsafe
        Erases all Port objects in Teams Admin Center without logging to file.

    .EXAMPLE
        Reset-TACProperty -Property "Port" -Unsafe -Confirm:$false
        Erases all Port objects in Teams Admin Center without logging to file and without confirmation.

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
        )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Property,

        [Parameter(Mandatory = $false)]
        [switch]$Unsafe
    )

    if ($PSBoundParameters.ContainsKey('Confirm') -and -not $PSBoundParameters['Confirm']) {
        # user explicitly did: -Confirm:$false
        return (Reset-Property -Property $Property -Unsafe:$Unsafe -Confirm:$false)
    }
    else {
        # otherwise, call with default confirmation behavior
        return (Reset-Property -Property $Property -Unsafe:$Unsafe)
    }
}

function Publish-TACProperty {
    <#
    .SYNOPSIS
        Upload all objects for a particular Property to Teams Admin Center.

    .DESCRIPTION
        This function uploads all objects for a particular Property into Teams Admin Center (e.g., CivicAddress, LocationSchema, Subnet, Switch, Port and WaP).
        It uses the MicrosoftTeams PowerShell Module to perform the operation. -Confirm switch is supported by this function.
        This function also checks the integrety of the data set by checking if the data schema matches MicrosoftTeams 6.9.0 scheme
        and that all required columns are present and not null as well as the presence of duplicate keys (Including composite keys)

        To get this menu use Get-Help Reset-TACProperty -Full
        To get list of all functions do: Get-Command -Module BackAtTAC -CommandType Function

    .PARAMETER Values (Mandatory)
        the data set to upload in the form of System.Object. You can use Read-TACData to load data set from a file.

    .PARAMETER Property (Mandatory)
        The type of property to whipe (e.g., CivicAddress, LocationSchema, Switch, Port, WaP).

    .INPUTS
        System.Object[] (Values)
        System.String[] (Property)

    .OUTPUTS
        System.Object[] (Uploaded objects collection)

    .EXAMPLE
        $MyValues = Read-TACData -Path "C:\Path\to\<Port_4506.csv>"
        Publish-TACProperty -Values $MyValues -Property "Port"
        Load all Port objects into Teams Admin Center.

    .EXAMPLE
        $MyValues = Read-TACData -Path "C:\Path\to\<Switch_4506.csv>"
        Publish-TACProperty -Values $MyValues -Property "Switch" -Confirm
        Load all Switch objects into Teams Admin Center but confirm before uploading.

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Property
    )

    return Publish-Property -Values $Values -Property $Property

}

# Export public functions
Export-ModuleMember -Function BackUp-TACData, Read-TACData, Reset-TACProperty, Publish-TACProperty

<#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ NOTES +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#__________________________ Function Additions and Bugs __________________________
# Add fast option to Read-TACData. (Use -AsJob for fast option)
# Add return value of a checksum to Write-File function. This will allow the user to verify the integrity of the file after writing it later
# Consider adding Write-Error $_.Exception.Message to catch errors.

<#
Error Checking and Logging: Implement some logging for job outcomes. For example, after a job finishes, check $job.State and $job.Error (or catch exceptions within the job scriptblock). 
If a job encountered an error, log it to a file or include it in the XML (perhaps as a special entry). This will help diagnose issues in scheduled runs where no one is watching the console. 
Logging the count of objects retrieved per category is also useful (e.g., “Exported 42 Teams, 10 Policies…”). 
This can be done in the main thread once results are in, and can be output to the console or a log file.
#>