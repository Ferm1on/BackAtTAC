# To Load this module do
# Import-Module .\BackAtTAC.psm1
# Get-Help BackUp-TACData -Full (or Read-TACCSV' or 'Read-TACXML)
# To unload Module do
# Remove-Module BackAtTAC
# To List Modules do
# Get-Module
# Dependencies: MicrosoftTeams, Powershell 7.5 or higher for -Fast option.
# To install Dependencies do:
# Install-Module -Name MicrosoftTeams -Force -AllowClobber

# Input: $FolderPath, $Object
# Output: Write $Object as <Property>_DDMM.xml or <Property>_DDMM.cvs to $FolderPath.
# Available Options: "CSV", "XML", "Fast"


# GLOBAL VARIABLES

# All Supported properties that can be backed up. To add a new property, add a new function to this hashtable. and increase the throttle limit value by 2
$All_Properties = @{
    CivicAddresses = { 
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $CivicAddresses = Get-CsOnlineLisCivicAddress
        if (-not $CivicAddresses -or $CivicAddresses.Count -eq 0) {
            Write-Verbose "No CivicAddresses found in Teams Admin Center; skipping CivicAddresses export."
            return
        }

        & $Write_File -FolderPath $Path -Property $CivicAddresses -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Locations = { 
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $Locations = Get-CsOnlineLisLocation
        if (-not $Locations -or $Locations.Count -eq 0) {
            Write-Verbose "No Locations found in Teams Admin Center; skipping Locations export."
            return
        }
        & $Write_File -FolderPath $Path -Property $Locations -CSV:$CSV -XML:$XML -Fast:$Fast
    
    }

    Subnets = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Subnets = Get-CsOnlineLisSubnet
        if (-not $Subnets -or $Subnets.Count -eq 0) {
            Write-Verbose "No Subnets found in Teams Admin Center; skipping Subnets export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Subnets -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Switches = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Switches = Get-CsOnlineLisSwitch
        if (-not $Switches -or $Switches.Count -eq 0) {
            Write-Verbose "No Switches found in Teams Admin Center; skipping Switches export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Switches -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Ports = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Ports = Get-CsOnlineLisPort
        if (-not $Ports -or $Ports.Count -eq 0) {
            Write-Verbose "No Ports found in Teams Admin Center; skipping Ports export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Ports -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    WirelessAccessPoints = { 
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $WirelessAccessPoints = Get-CsOnlineLisWirelessAccessPoint
        if (-not $WirelessAccessPoints -or $WirelessAccessPoints.Count -eq 0) {
            Write-Verbose "No WirelessAccessPoints found in Teams Admin Center; skipping WirelessAccessPoints export."
            return
        }

        & $Write_File -FolderPath $Path -Property $WirelessAccessPoints -CSV:$CSV -XML:$XML -Fast:$Fast
    }
}

# Throttle limit for the number of threads to run in parallel. Should be equal to the number of properties in $All_Properties*2
$ThrottleLimit = 12

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

    #---------------------------------- ERROR CHECKING START----------------------------------
    # In Write-File, right at the top after the parameters:
    if (-not $Property -or $Property.Count -eq 0) {
        Write-Warning "Write-File: The provided object is null or empty, skipping export."
        return
    }
    #---------------------------------- ERROR CHECKING END----------------------------------

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
            # in Parallel
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
            $Property | Export-Csv -Path "$FullFilePath.csv" -NoTypeInformation -Force  
        #Export the object to XML
        } elseif ($XML) {
            $Property | Export-Clixml -Path "$FullFilePath.xml" -Force
        # Export the object to both CSV and XML
        } 

        return

    } catch {
        Write-Error $_.Exception.Message
        return $false
    }
}
$Write_File = [ScriptBlock]::Create((Get-Command Write-File -CommandType Function).Definition)

# Main public function that user interacts with. Backs up Teams Admin Center data.
function BackUp-TACData {
    <#
    .SYNOPSIS
        Backs up Teams Admin Center data through 'MicrosoftTeams' PowerShell Module.
    
    .DESCRIPTION
        Backs up property data from Microsoft Teams Admin Center (e.g., CivicAddresses, Locations, Switches etc.).
        Allows optional multithreading for faster (default is slow) exports, uses switches for CSV/XML export preferences,
        and can optionally filter which properties are backed up. 
        Default: All properties are backed up and exported in both CSV and XML formats. Default file name for backups are '<Property>_DDMM.csv' and '<Property>_DDMM.xml'.
        To get this menu use Get-Help BackUp-TACData -Full
    
    .PARAMETER Path (Mandatory)
        The target directory to store exported backup files.

    .PARAMETER Properties (Optional)
        An array of Teams Admin Center property names to export (e.g., 'CivicAddresses', 'Locations'). If omitted, all properties are exported.
        Currently supported properties: 'CivicAddresses', 'Locations', 'Subnets', 'Switches', 'Ports', 'WirelessAccessPoints'.

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
        BackUp-TACData -Path "C:\\TACBackup" -Properties "CivicAddresses","Locations" -CSV -Fast 
        Backs up CivicAddresses and Locations as CSV, using multithreading (Fast).

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

    #---------------------------------- ERROR CHECKING START----------------------------------
    # ERROR CHECKING for $FolderPath: Checking if path exists
    if (-not (Test-Path -Path $Path)) {
        Write-Error "Invalid FolderPath: $Path"
        return $False
    }

    # ERROR CHECKING for $Properties: Checking all user submited properties are supported
    foreach ($Property in $Properties) {
        if (-not $All_Properties.ContainsKey($Property)) {
            Write-Error "This module does not support the backup of '$Property' property."
            return $False
        }
    }
    #---------------------------------- ERROR CHECKING END----------------------------------

    try {
        # Backing Up All Properties
         # Fast Option, Backup all properties in parallel. If not selected, backup properties sequentially.
        if($Fast) {
            $jobs = @()
      
              # Backup all properties else Backup selected properties.
              if(-not $Properties -or $Properties.Count -eq 0) {
      
                  foreach ($Property in $All_Properties.Values) {
                      $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast
                  }
      
              } else {
      
                  foreach ($Property in $Properties) {
                      $Jobs += Start-ThreadJob -ThrottleLimit $ThrottleLimit  -ScriptBlock $All_Properties.($Property) -ArgumentList $Path, $Write_File, $CSV, $XML, $Fast
                  }
              }
      
              # Clean up jobs.
              $Jobs | Wait-Job | Receive-Job
              $jobs | Remove-Job
      
          } else {
              # Sequential processing of the functions
              # Backup all properties else Backup selected properties.
              if(-not $Properties -or $Properties.Count -eq 0) {
      
                  foreach ($Property in $All_Properties.Values) {
                      & $Property -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast
                  }
                  
              } else {
      
                  foreach ($Property in $Properties) {
                      & $All_Properties.($Property) -Path $Path -Write_File $Write_File -CSV:$CSV -XML:$XML -Fast:$Fast
                  }
              }
          }
          
          return

    } catch {
        Write-Error "Failure on BackUp-TACData function"
        Write-Error $_.Exception.Message
        return $false
    }
    
}

# Public function to read an CSV file and return a System.Object
function Read-TACCSV {
    <#
    .SYNOPSIS
        Reads a CSV file and returns the content as a System.Object array.

    .DESCRIPTION
        Reads a CSV file using Import-Csv and returns the resulting objects as a collection.

    .PARAMETER Path
        The full file path to the CSV file to import.
    
    .INPUTS
        System.String (Path)
    .OUTPUTS
        System.Object[] (CSV Data)

    .EXAMPLE
        $csvData = Read-TACCSV -Path "C:\Path\to\yourfile.csv"
        Imports data from the specified CSV file into $csvData.

    .NOTES
        This script is provided as-is and is not supported by me. Please test before using it in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Read-CsvFile: CSV file not found at path: $CsvFilePath"
        return $null
    }

    try {
        $CsvObject = Import-Csv -Path $Path
        return $CsvObject
    }
    catch {
        
        Write-Error "Failed to import CSV file: $_"
        Write-Error $_.Exception.Message
        return $null
    }
}

# Public function to read an XML file and return a System.Object
function Read-TACXML {
    <#
    .SYNOPSIS
        Reads an XML file and returns the content as a System.Object.

    .DESCRIPTION
        Reads an XML file exported using Export-Clixml and returns the resulting object.

    .PARAMETER Path
        The full file path to the XML file to import.

    .INPUTS
        System.String (Path)

    .OUTPUTS
        System.Object[] (XML Data)

    .EXAMPLE
        $xmlData = Read-TACXML -Path "C:\Path\to\yourfile.xml"
        Imports data from the specified XML file into $xmlData.
    .NOTES
        This script is provided as-is and is not supported by me. Please test before using in a production environment.
        If you modify the script, please give credit to the original author.
        Author: Ferm1on
        "Dream of electric sheep."
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        $XmlObject = Import-Clixml -Path $Path
        return $XmlObject
    }
    catch {
        Write-Error "Failed to import XML file: $_"
        Write-Error $_.Exception.Message
        return $null
    }
}

# Export the functions
Export-ModuleMember -Function BackUp-TACData, Read-TACCSV, Read-TACXML

#__________________________ Function Additions and Bugs __________________________
# Add more Verbose Options
# Add Teams Admin Center data backup upload function. (Dangerous as it will overwrite server data)
# Remove #FileName option. User does not need to add file name.
# Add error check for Connect-MicrosoftTeams. Test connection and test permissions.
# Add fast option to Read-TACCSV and Read-TACXML. (Use -AsJob for fast option)
# Add a -Force option to the Write-File function to overwrite existing files without prompting.

<#
Error Checking and Logging: Implement some logging for job outcomes. For example, after a job finishes, check $job.State and $job.Error (or catch exceptions within the job scriptblock). 
If a job encountered an error, log it to a file or include it in the XML (perhaps as a special entry). This will help diagnose issues in scheduled runs where no one is watching the console. 
Logging the count of objects retrieved per category is also useful (e.g., “Exported 42 Teams, 10 Policies…”). 
This can be done in the main thread once results are in, and can be output to the console or a log file.
#>