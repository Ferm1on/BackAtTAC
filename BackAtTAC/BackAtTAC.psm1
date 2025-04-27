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
Import-Module .\BackAtTAC.psm1
Get-Help BackUp-TACData -Full (or Read-TACCSV' or 'Read-TACXML)
To unload Module do
Remove-Module BackAtTAC
To List Modules do
Get-Module
Dependencies: MicrosoftTeams, Powershell 7.5 or higher for -Fast option.
To install Dependencies do:
Install-Module -Name MicrosoftTeams -Force -AllowClobber

Input: $FolderPath, $Object
Output: Write $Object as <Property>_DDMM.xml or <Property>_DDMM.cvs to $FolderPath.
Available Options: "CSV", "XML", "Fast"
#>

#---------------------------------------------- GLOBAL VARIABLES ----------------------------------------------

# All Supported properties that can be backed up. To add a new property...
#   1. Add a new function to $All_Properties_Exporters hashtable. 
#   2. Add new entry to $All_Properties_Parameters with proterty table schema and required fields.
#   3. Increase the throttle limit value by 2
$All_Properties_Exporters = @{
    CivicAddress = { 
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $CivicAddress = Get-CsOnlineLisCivicAddress
        if (-not $CivicAddress -or $CivicAddress.Count -eq 0) {
            Write-Verbose "No CivicAddress found in Teams Admin Center; skipping CivicAddress export."
            return
        }

        & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    LocationSchema = { 
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $LocationSchema = Get-CsOnlineLisLocation
        if (-not $LocationSchema -or $LocationSchema.Count -eq 0) {
            Write-Verbose "No LocationSchema found in Teams Admin Center; skipping LocationSchema export."
            return
        }
        & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast
    
    }

    Subnet = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Subnet = Get-CsOnlineLisSubnet
        if (-not $Subnet -or $Subnet.Count -eq 0) {
            Write-Verbose "No Subnet found in Teams Admin Center; skipping Subnet export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Switch = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Switch = Get-CsOnlineLisSwitch
        if (-not $Switch -or $Switch.Count -eq 0) {
            Write-Verbose "No Switch found in Teams Admin Center; skipping Switch export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Port = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Port = Get-CsOnlineLisPort
        if (-not $Port -or $Port.Count -eq 0) {
            Write-Verbose "No Port found in Teams Admin Center; skipping Port export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    WAP = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $WAP = Get-CsOnlineLisWirelessAccessPoint
        if (-not $WAP -or $WAP.Count -eq 0) {
            Write-Verbose "No WAP found in Teams Admin Center; skipping WAP export."
            return
        }

        & $Write_File -FolderPath $Path -Property $WAP -CSV:$CSV -XML:$XML -Fast:$Fast
    }
}

# Parammaters for file validation Extracted from Backup Files for MicrosoftTeams Powershell module Version 7.0.0
# item2 denotes if the property is required or not. If true, the property is required.
$All_Properties_Parameters = @{

    CivicAddress = @(
        [System.Tuple[string,bool]]::New("AdditionalLocationInfo",  $false)
        [System.Tuple[string,bool]]::New("City",                    $false)
        [System.Tuple[string,bool]]::New("CityAlias",               $false)
        [System.Tuple[string,bool]]::New("CivicAddressId",          $false)
        [System.Tuple[string,bool]]::New("CompanyName",             $false)
        [System.Tuple[string,bool]]::New("CompanyTaxId",            $false)
        [System.Tuple[string,bool]]::New("Confidence",              $false)
        [System.Tuple[string,bool]]::New("CountryOrRegion",         $false)
        [System.Tuple[string,bool]]::New("CountyOrDistrict",        $false)
        [System.Tuple[string,bool]]::New("DefaultLocationId",       $false)
        [System.Tuple[string,bool]]::New("Description",             $false)
        [System.Tuple[string,bool]]::New("Elin",                    $false)
        [System.Tuple[string,bool]]::New("HouseNumber",             $false)
        [System.Tuple[string,bool]]::New("HouseNumberSuffix",       $false)
        [System.Tuple[string,bool]]::New("Latitude",                $false)
        [System.Tuple[string,bool]]::New("Longitude",               $false)
        [System.Tuple[string,bool]]::New("NumberOfTelephoneNumbers",$false)
        [System.Tuple[string,bool]]::New("NumberOfVoiceUsers",      $false)
        [System.Tuple[string,bool]]::New("PartnerId",               $false)
        [System.Tuple[string,bool]]::New("PostDirectional",         $false)
        [System.Tuple[string,bool]]::New("PostalCode",              $false)
        [System.Tuple[string,bool]]::New("PreDirectional",          $false)
        [System.Tuple[string,bool]]::New("StateOrProvince",         $false)
        [System.Tuple[string,bool]]::New("StreetName",              $false)
        [System.Tuple[string,bool]]::New("StreetSuffix",            $false)
        [System.Tuple[string,bool]]::New("TenantId",                $false)
        [System.Tuple[string,bool]]::New("ValidationStatus",        $false)
    )

    LocationSchema = @(
        [System.Tuple[string,bool]]::New("City",                    $false)
        [System.Tuple[string,bool]]::New("CityAlias",               $false)
        [System.Tuple[string,bool]]::New("CivicAddressId",          $false)
        [System.Tuple[string,bool]]::New("CompanyName",             $false)
        [System.Tuple[string,bool]]::New("CompanyTaxId",            $false)
        [System.Tuple[string,bool]]::New("Confidence",              $false)
        [System.Tuple[string,bool]]::New("CountryOrRegion",         $false)
        [System.Tuple[string,bool]]::New("CountyOrDistrict",        $false)
        [System.Tuple[string,bool]]::New("Description",             $false)
        [System.Tuple[string,bool]]::New("Elin",                    $false)
        [System.Tuple[string,bool]]::New("HouseNumber",             $false)
        [System.Tuple[string,bool]]::New("HouseNumberSuffix",       $false)
        [System.Tuple[string,bool]]::New("IsDefault",               $false)
        [System.Tuple[string,bool]]::New("Latitude",                $false)
        [System.Tuple[string,bool]]::New("Location",                $false)
        [System.Tuple[string,bool]]::New("LocationId",              $false)
        [System.Tuple[string,bool]]::New("Longitude",               $false)
        [System.Tuple[string,bool]]::New("NumberOfTelephoneNumbers",$false)
        [System.Tuple[string,bool]]::New("NumberOfVoiceUsers",      $false)
        [System.Tuple[string,bool]]::New("PartnerId",               $false)
        [System.Tuple[string,bool]]::New("PostDirectional",         $false)
        [System.Tuple[string,bool]]::New("PostalCode",              $false)
        [System.Tuple[string,bool]]::New("PreDirectional",          $false)
        [System.Tuple[string,bool]]::New("StateOrProvince",         $false)
        [System.Tuple[string,bool]]::New("StreetName",              $false)
        [System.Tuple[string,bool]]::New("StreetSuffix",            $false)
        [System.Tuple[string,bool]]::New("TenantId",                $false)
        [System.Tuple[string,bool]]::New("ValidationStatus",        $false)
    )

    Subnet = @(
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $false)
        [System.Tuple[string,bool]]::New("Subnet",      $false)
    )

    Switch = @(
        [System.Tuple[string,bool]]::New("ChassisId",   $false)
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $false)
    )

    Port = @(
        [System.Tuple[string,bool]]::New("",            $false)
    )

    WAP = @(
        [System.Tuple[string,bool]]::New("Bssid",       $false)
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $false)
    )
}

# Throttle limit for the number of threads to run in parallel. Should be equal to the number of properties in $All_Properties_Exporters*2
$ThrottleLimit = 12

#---------------------------------------- PRIVATE FUNCTION DEFINITIONS ----------------------------------------

# Write a file to the specified path. The file name is generated dynamically based on the property type and current date.
function Write-File {
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

            } else {
                # Sequential 
                $Property | Export-Csv -Path "$FullFilePath.csv" -NoTypeInformation -Force
                $Property | Export-Clixml -Path "$FullFilePath.xml" -Force
            }
        }
        elseif ($CSV) {
            # Export the object to CSV
            $Property | Export-Csv -Path "$FullFilePath.csv" -NoTypeInformation -Force  
        } elseif ($XML) {
            # Export the object to XML
            $Property | Export-Clixml -Path "$FullFilePath.xml" -Force
        } 

        return

    } catch {
        Write-Error $_.Exception.Message # <-- Log the error message is possibly not behaving as intented FIX
        return
    }
}
$Write_File = [ScriptBlock]::Create((Get-Command Write-File -CommandType Function).Definition)

# Reads backup file with integrity checking. 
# This fuction checks if the file is a CSV or XML file, and that the file schema matches the MicrosoftTeams 7.0.0 scheme.
# Optionally, you can pass a SHA256 checksum to validate the file integrity further.
function Read-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$PropertyType,

        [Parameter(Mandatory=$false)]
        [string]$Checksum = $null
    )

    #------------------------------------------ ERROR CHECKING START ------------------------------------------

    # Check if the path is valid
    if (-not (Test-Path -Path $Path)) {
        Write-Error "Read-CsvFile: CSV file not found at path: $Path"
        return
    }

    # If provided, check if checksum matches.
    if ($Checksum) {
        if ((Get-FileHash -Path $Path -Algorithm SHA256).Hash -eq $Checksum) {
            Write-Verbose "File checksum integrity check passed."
        } else {
            Write-Error "File integrity check failed. File may be corrupted."
            return
        }
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------

    if ($Path -match '\.(csv)$') {
        # Importing CSV file
        try {
            # Load the CSV
            $CsvObject = Import-Csv -Path $Path
        
            # Check existence and non-null for each column in CSV schema
            foreach ($tuple in $All_Properties_Parameters[$PropertyType]) {
                $colName    = $tuple.Item1
                $isRequired = $tuple.Item2
        
                # Check Column existence
                if (-not ($CsvObject[0].PSObject.Properties.Name -contains $colName)) {
                    if ($isRequired) {
                        Write-Error "$colName column is required, CSV not loaded"
                        return
                    }
                    else {
                        Write-Verbose "$colName does not exist"
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
                        Write-Error "Required column '$colName' has empty values at CSV line(s): $($badLines -join ', ')"
                        return
                    }
                }
            }

            Write-Verbose "CSV file: $Path passed attribute integrity check."
            Write-Verbose "Imported $Path to enviroment."
            return $CsvObject
        }
        catch { 
            Write-Error "Failed to import CSV file: $_"
            return
        }

    } elseif ($Path -match '\.(xml)$'){
        try {
            $XmlObject = Import-Clixml -Path $Path

            # Check existence and non-null for each column in XML schema
            foreach ($tuple in $All_Properties_Parameters[$PropertyType]) {
                $colName    = $tuple.Item1
                $isRequired = $tuple.Item2

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
                }
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


#---------------------------------------- PUBLIC FUNCTION DEFINITIONS -----------------------------------------

# Backs up Teams Admin Center data.
function BackUp-TACData {
    <#
    .SYNOPSIS
        Backs up Teams Admin Center data through 'MicrosoftTeams' PowerShell Module.
    
    .DESCRIPTION
        Backs up property data from Microsoft Teams Admin Center (e.g., CivicAddress, LocationSchema, Switch etc.).
        Allows optional multithreading for faster (default is slow) export, uses switch for CSV/XML export preferences,
        and can optionally filter which properties are backed up. 
        Default: All properties are backed up and exported in both CSV and XML formats. Default file name for backups are '<Property>_DDMM.csv' and '<Property>_DDMM.xml'.
        To get this menu use Get-Help BackUp-TACData -Full
    
    .PARAMETER Path (Mandatory)
        The target directory to store exported backup files.

    .PARAMETER Properties (Optional)
        An array of Teams Admin Center property names to export (e.g., 'CivicAddress', 'LocationSchema'). If omitted, all properties are exported.
        Currently supported properties: 'CivicAddress', 'LocationSchema', 'Subnet', 'Switch', 'Port', 'WAP'.

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
        Write-Error "Invalid FolderPath: $Path"
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

    try {
        # Backing Up All Properties
         # Fast Option, Backup all properties in parallel. If not selected, backup properties sequentially.
        if($Fast) {
            $jobs = @()
      
              # Backup all properties else Backup selected properties.
              if(-not $Properties -or $Properties.Count -eq 0) {
      
                  foreach ($Property in $All_Properties_Exporters.Values) {
                      $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast
                  }
      
              } else {
      
                  foreach ($Property in $Properties) {
                      $Jobs += Start-ThreadJob -ThrottleLimit $ThrottleLimit  -ScriptBlock $All_Properties_Exporters
                    .($Property) -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast
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
                      & $Property -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast
                  }
                  
              } else {
      
                  foreach ($Property in $Properties) {
                      & $All_Properties_Exporters.($Property) -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast
                  }
              }
          }
          
          return

    } catch {
        Write-Error "Failure on BackUp-TACData function"
        Write-Error $_.Exception.Message
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
        This function checks the integrety of the backup file by checking if file schema matches MicrosoftTeams 7.0.0 scheme
        and that all required columns are present and not null.
        Optionally, you pay pass a SHA256 checksum to validate the file integrity further.

    .PARAMETER Path
        The full file path to the backup file to import.
    
    .PARAMETER PropertyType
        The type of property to import (e.g., CivicAddress, LocationSchemachema, Switch, Port, WAP).
    
    .PARAMETER Checksum
        The SHA256 checksum of the backup file to validate its integrity.
    
    .INPUTS
        System.String (Path)
        System.String (PropertyType)
        System.String (Checksum)

    .OUTPUTS
        System.Object (Backup data)

    .EXAMPLE
        $csvData = Read-TACData -Path "C:\Path\to\<yourfile.csv>" -PropertyType "CivicAddress" -Checksum "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        Import data from the specified file into $csvData.

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$PropertyType,

        [Parameter(Mandatory=$false)]
         [string]$Checksum = $null
    )
    # Variables declared in the function scope
    return Read-File -Path $Path -PropertyType $PropertyType -Checksum $Checksum
}

# Export public functions
Export-ModuleMember -Function BackUp-TACData, Read-TACData

<#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ NOTES +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#__________________________ Function Additions and Bugs __________________________
# Add more Verbose Options
# Add Teams Admin Center data backup upload function. (Dangerous as it will overwrite server data)
# Add error check for Connect-MicrosoftTeams. Test connection and test permissions.
# Add fast option to Read-TACData. (Use -AsJob for fast option)
# Add a -Force option to the Write-File function to overwrite existing files without prompting.
# Add return value of a checksum to Write-File function. This will allow the user to verify the integrity of the file after writing it later

<#
Error Checking and Logging: Implement some logging for job outcomes. For example, after a job finishes, check $job.State and $job.Error (or catch exceptions within the job scriptblock). 
If a job encountered an error, log it to a file or include it in the XML (perhaps as a special entry). This will help diagnose issues in scheduled runs where no one is watching the console. 
Logging the count of objects retrieved per category is also useful (e.g., “Exported 42 Teams, 10 Policies…”). 
This can be done in the main thread once results are in, and can be output to the console or a log file.
#>