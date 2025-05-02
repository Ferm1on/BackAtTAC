# to Test Read-File and Read-TACData Function load the functions and BackAtTAC_Globals.psm1 variables file.
# You should also be in a directory with backed up files to load.

# Test Get-Help output works properly
Get-Help Read-TACData -Full

#----------------------------------------- Check CivicAddresses -----------------------------------------
# Test simple load CSV CivicAddresses file.
$CivicASum = (Get-FileHash -PAth .\CivicAddress_1503.csv -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress
$CivicA
# Test simple load CSV CivicAddresses with good checksum Validation
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicASum
# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Verbose
# Test verbose with good checksum
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicASum -Verbose
# Test Bad checksum
$CivicASum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicASum
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicASum -Verbose

# Test simple load Xml CivicAddresses file.
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -Propertties CivicAddress
$CivicB
# Test simple load XML CivicAddresses with good checksum Validation
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -Propertties CivicAddress -Checksum $CivicBSum
# Test verbose proper propagation.
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -Propertties CivicAddress -Verbose
# Test verbose with good checksum
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -Propertties CivicAddress -Checksum $CivicBSum -Verbose
# Test Bad checksum
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicBSum
$CivicB = Read-TACData -Path .\CivicAddress_1503.csv -Propertties CivicAddress -Checksum $CivicBSum -Verbose

# Compare CVS and XML File
if (-not (Compare-Object $CivicA $CivicB)) {
    'Arrays are equal'
} else {
    'Arrays differ'
}
#----------------------------------------- Check CivicAddresses -----------------------------------------


# Test simple load CSV LocationSchemas file.
$LocationA = Read-TACData -Path .\LocationSchema_1503.csv -Propertties LocationSchema
$LocationA

# Test simple load CSV Subnet file.
$SubnetA = Read-TACData -Path .\Subnet_1503.csv -Propertties Subnet
$SubnetA

# Test simple load CSV Switch file.
$SwitchA = Read-TACData -Path .\Switch_1503.csv -Propertties Switch
$SwitchA

# Test simple load CSV WAP file.
$WAPA = Read-TACData -Path .\Switch_1503.csv -Propertties WAP
$WAPA


# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -Properties CivicAddress -Verbose

#---------------------------------- Check $Properties and $Path arrays ----------------------------------
$Properties = @(
    'CivicAddress',
    'LocationSchema',
    'Subnet',
    'Switch',
    'WAP'
)
$PathCSV = @(
    '.\CivicAddress_2404.csv',
    '.\LocationSchema_2404.csv',
    '.\Subnet_2404.csv',
    '.\Switch_2404.csv',
    '.\WaP_2404.csv'
)
$PathXML = @(
    '.\CivicAddress_2404.xml',
    '.\LocationSchema_2404.xml',
    '.\Subnet_2404.xml',
    '.\Switch_2404.xml',
    '.\WaP_2404.xml'
)

# testing mmulti import of files with Auto properties guess
Read-TACData -Path $PathCSV

# Testing multi import of files with especified Properties
Read-TACData -Path $PathCSV -Properties $Properties

# Smaller arrays for testing
$Properties = @(
    'Subnet',
    'Switch'
)

$PathCSV = @(
    '.\Subnet_2404.csv',
    '.\Switch_2404.csv'
)

# To test multiple imports at once do.
$MyValue = @(Read-TACDAta -Path $PathCSV -Properties $Properties) 
# MyValue will be an array of all objects

# Get checksum for files SHA246
$All_Hashes = [System.Collections.ArrayList]::new()

foreach ($File in $PathCSV) {
    $FileHash = Get-FileHash -Path $File -Algorithm SHA256
    $All_Hashes.Add($FileHash) | Out-Null
}

# Build only hash array
$HashArray = @()

foreach ($Hash in $All_Hashes) {
    $HashArray += $Hash.Hash
}

# Read all files with checksum validation
$MyValue = Read-TACDAta -Path $PathCSV -Properties $Properties -Checksum $HashArray

# Test if -Checksum array is the wrong size.
$Bad_HashArray = @()
for ($i = 0; $i -lt ($HashArray.Count -1 ); $i++) {
    $Bad_HashArray += $HashArray[$i]
}
$MyValue = Read-TACDAta -Path $PathCSV -Properties $Properties -Checksum $Bad_HashArray

# Testing bad Properties array size.
$Bad_Properties = @(
    'Subnet',
    'Switch',
    'WAP'
)
$MyValue = Read-TACDAta -Path $PathCSV -Properties $Bad_Properties -Checksum $HashArray

# Testing unsupported property inside property array.
$Bad_Properties = @(
    'CivicAddress',
    'Subnet',
    'Switch',
    'WAP',
    'BadProperty'
)
$MyValue = Read-TACDAta -Path $PathCSV -Properties $Bad_Properties -Checksum $HashArray

# Testing file missing "Description" attribute, i.e. missing column.
# The file bellow is missing description information
$MyValue =  Read-TACData -Path .\CivicAddress_MissingColumn.csv


# Testing file missing required "Company" attribute, i.e. missing column.
# The file bellow is missing company information
$MyValue =  Read-TACData -Path .\LocationSchema_MissingRColumn.csv

if (-not ($CsvObject[0].PSObject.Properties.Name -contains $colName)) {
    if ($isRequired) {
        Write-Host "$colName column is required, CSV not loaded"
        return
    }
    else {
        Write-Host "$colName does not exist"
        continue
    }
}


read-file .\CivicAddress_2404.xml -Property CivicAddress 

#----------------------------------------------------------------------------------------------------------------

$All_Properties_Parameters = @{

    CivicAddress = @(
        [System.Tuple[string,bool]]::New("AdditionalLocationInfo",  $false)
        [System.Tuple[string,bool]]::New("City",                    $false)
        [System.Tuple[string,bool]]::New("CityAlias",               $false)
        [System.Tuple[string,bool]]::New("CivicAddressId",          $true )
        [System.Tuple[string,bool]]::New("CompanyName",             $true )
        [System.Tuple[string,bool]]::New("CompanyTaxId",            $false)
        [System.Tuple[string,bool]]::New("Confidence",              $false)
        [System.Tuple[string,bool]]::New("CountryOrRegion",         $true )
        [System.Tuple[string,bool]]::New("CountyOrDistrict",        $false)
        [System.Tuple[string,bool]]::New("DefaultLocationId",       $true )
        [System.Tuple[string,bool]]::New("Description",             $false)
        [System.Tuple[string,bool]]::New("Elin",                    $false)
        [System.Tuple[string,bool]]::New("HouseNumber",             $false)
        [System.Tuple[string,bool]]::New("HouseNumberSuffix",       $false)
        [System.Tuple[string,bool]]::New("Latitude",                $true )
        [System.Tuple[string,bool]]::New("Longitude",               $true )
        [System.Tuple[string,bool]]::New("NumberOfTelephoneNumbers",$false)
        [System.Tuple[string,bool]]::New("NumberOfVoiceUsers",      $false)
        [System.Tuple[string,bool]]::New("PartnerId",               $false)
        [System.Tuple[string,bool]]::New("PostDirectional",         $false)
        [System.Tuple[string,bool]]::New("PostalCode",              $false)
        [System.Tuple[string,bool]]::New("PreDirectional",          $false)
        [System.Tuple[string,bool]]::New("StateOrProvince",         $false)
        [System.Tuple[string,bool]]::New("StreetName",              $false)
        [System.Tuple[string,bool]]::New("StreetSuffix",            $false)
        [System.Tuple[string,bool]]::New("TenantId",                $true )
        [System.Tuple[string,bool]]::New("ValidationStatus",        $false)
    )

    LocationSchema = @(
        [System.Tuple[string,bool]]::New("City",                    $false)
        [System.Tuple[string,bool]]::New("CityAlias",               $false)
        [System.Tuple[string,bool]]::New("CivicAddressId",          $true )
        [System.Tuple[string,bool]]::New("CompanyName",             $true)
        [System.Tuple[string,bool]]::New("CompanyTaxId",            $false)
        [System.Tuple[string,bool]]::New("Confidence",              $false)
        [System.Tuple[string,bool]]::New("CountryOrRegion",         $true )
        [System.Tuple[string,bool]]::New("CountyOrDistrict",        $false)
        [System.Tuple[string,bool]]::New("Description",             $false)
        [System.Tuple[string,bool]]::New("Elin",                    $false)
        [System.Tuple[string,bool]]::New("HouseNumber",             $false)
        [System.Tuple[string,bool]]::New("HouseNumberSuffix",       $false)
        [System.Tuple[string,bool]]::New("IsDefault",               $false)
        [System.Tuple[string,bool]]::New("Latitude",                $true )
        [System.Tuple[string,bool]]::New("Location",                $false)
        [System.Tuple[string,bool]]::New("LocationId",              $true )
        [System.Tuple[string,bool]]::New("Longitude",               $true )
        [System.Tuple[string,bool]]::New("NumberOfTelephoneNumbers",$false)
        [System.Tuple[string,bool]]::New("NumberOfVoiceUsers",      $false)
        [System.Tuple[string,bool]]::New("PartnerId",               $false)
        [System.Tuple[string,bool]]::New("PostDirectional",         $false)
        [System.Tuple[string,bool]]::New("PostalCode",              $false)
        [System.Tuple[string,bool]]::New("PreDirectional",          $false)
        [System.Tuple[string,bool]]::New("StateOrProvince",         $false)
        [System.Tuple[string,bool]]::New("StreetName",              $false)
        [System.Tuple[string,bool]]::New("StreetSuffix",            $false)
        [System.Tuple[string,bool]]::New("TenantId",                $true )
        [System.Tuple[string,bool]]::New("ValidationStatus",        $false)
    )

    Subnet = @(
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $true )
        [System.Tuple[string,bool]]::New("Subnet",      $true )
    )

    Switch = @(
        [System.Tuple[string,bool]]::New("ChassisId",   $true )
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $true )
    )

    Port = @(
        [System.Tuple[string,bool]]::New("PortID",      $true )
        [System.Tuple[string,bool]]::New("ChassisID",   $true)
        [System.Tuple[string,bool]]::New("LocationId",  $true)
        [System.Tuple[string,bool]]::New("Description", $false)
    )

    WaP = @(
        [System.Tuple[string,bool]]::New("Bssid",       $true)
        [System.Tuple[string,bool]]::New("Description", $false)
        [System.Tuple[string,bool]]::New("LocationId",  $true)
    )
}

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
            Write-Error "File integrity check failed. File may be corrupted or wrong file input."
            return
        }
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------

    if ($Path -match '\.(csv)$') {
        # Importing CSV file
        try {
            # Load the CSV
            $CsvObject = Import-Csv -Path $Path
        
            Write-Host "The property is $Property"
            Write-Host "The type is $($Property.gettype())"

            # Check existence and non-null for each column in CSV schema
            foreach ($tuple in $All_Properties_Parameters[$Property]) {

                Write-Host "$Property"
                Write-Host "$($Property.gettype())"

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
                        Write-Error "Required column '$colName' on $Path has empty values at CSV line(s): $($badLines -join ', ')"
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
            foreach ($tuple in $All_Properties_Parameters[$Property]) {
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

# Reads an CSV or XML file and return a System.ObjectRead
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
    
    .PARAMETER Properties
        The type of property to import (e.g., CivicAddress, LocationSchemachema, Switch, Port, WaP).
    
    .PARAMETER Checksum
        The SHA256 checksum of the backup file to validate its integrity.
    
    .INPUTS
        System.String (Path)
        System.String (Properties)
        System.String (Checksum)

    .OUTPUTS
        System.Object (Backup data)

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
                  
                Write-Host "Key is: $key"
                Write-Host "Property Built Before Canonical: $Properties"
                Write-Host "Canonical: $canonical"
    
                $Properties += $canonical

                Write-Host "Property Built: $Properties"
                Write-Host "Property Type:  $($Properties.gettype())"
            }
            catch {
                Write-Error $_
                return
            }
        }
    } else {
         # Check $Properties Array size against $Path array size.
        if (-Not ($Path.Count -eq $Properties.Count)){
            Write-Error "Properties array not the same length as Path array"
            return
        }
        
        # Test if provided Properties are valid find any entries that aren’t valid keys
        $invalid = $Properties | Where-Object { -not $All_Properties_Parameters.ContainsKey($_) }
    
        if ($invalid) {
            throw "Invalid property key(s): $($invalid -join ', '). `nAllowed properties are: $($All_Properties_Parameters.Keys -join ', ')"
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
    }
    #------------------------------------------- ERROR CHECKING END -------------------------------------------
    
    if($Checksum){
        # If checksum is provided, call function with checksum.
        for ($i = 0; $i -lt $Path.Count; $i++) {
            $File     = $Path[$i]
            $Property = $Properties[$i]
            $Hash = $Checksum[$i]
        
            try {
                $data = Read-File -Path $File -Property $Property -Checksum $Hash
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
                $data = Read-File -Path $File -Property $Property
                $Backup_Files.Add($data) | Out-Null
            }
            catch {
                Write-Error "Failed to import file: $_"
                return
            }
        }
    }
    # Return array of imported data
    return $Backup_Files
}

