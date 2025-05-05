# to Test Read-File and Read-TACData Function load the functions and BackAtTAC_Globals.psm1 variables file.
# You should also be in a directory with backed up files to load.

# Test Get-Help output works properly
Get-Help Read-TACData -Full

#----------------------------------------- Check CivicAddresses -----------------------------------------
# Test simple load CSV CivicAddresses file.
$CivicASum = (Get-FileHash -PAth .\CivicAddress_0405.csv -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress
$CivicA
# Test simple load CSV CivicAddresses with good checksum Validation
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicASum
# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Verbose
# Test verbose with good checksum
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicASum -Verbose
# Test Bad checksum
$CivicASum = (Get-FileHash -PAth .\CivicAddress_0405.xml -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicASum
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicASum -Verbose

# Test simple load Xml CivicAddresses file.
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_0405.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_0405.xml -Properties CivicAddress
$CivicB
# Test simple load XML CivicAddresses with good checksum Validation
$CivicB = Read-TACData -Path .\CivicAddress_0405.xml -Properties CivicAddress -Checksum $CivicBSum
# Test verbose proper propagation.
$CivicB = Read-TACData -Path .\CivicAddress_0405.xml -Propertties CivicAddress -Verbose
# Test verbose with good checksum
$CivicB = Read-TACData -Path .\CivicAddress_0405.xml -Properties CivicAddress -Checksum $CivicBSum -Verbose
# Test Bad checksum
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_0405.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicBSum
$CivicB = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Checksum $CivicBSum -Verbose

# Compare CVS and XML File
if (-not (Compare-Object $CivicA $CivicB)) {
    'Arrays are equal'
} else {
    'Arrays differ'
}
#----------------------------------------- Check CivicAddresses -----------------------------------------


# Test simple load CSV LocationSchemas file.
$LocationA = Read-TACData -Path .\LocationSchema_0405.csv -Properties LocationSchema
$LocationA

# Test simple load CSV Subnet file.
$SubnetA = Read-TACData -Path .\Subnet_0405.csv -Properties Subnet
$SubnetA

# Test simple load CSV Switch file.
$SwitchA = Read-TACData -Path .\Switch_0405.csv -Properties Switch
$SwitchA

# Test simple load CSV WAP file.
$WAPA = Read-TACData -Path .\WaP_0405.csv -Properties WAP
$WAPA


# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_0405.csv -Properties CivicAddress -Verbose

#---------------------------------- Check $Properties and $Path arrays ----------------------------------
$Properties = @(
    'CivicAddress',
    'LocationSchema',
    'Subnet',
    'Switch',
    'WAP'
)
$PathCSV = @(
    '.\CivicAddress_0405.csv',
    '.\LocationSchema_0405.csv',
    '.\Subnet_0405.csv',
    '.\Switch_0405.csv',
    '.\WaP_0405.csv'
)
$PathXML = @(
    '.\CivicAddress_0405.xml',
    '.\LocationSchema_0405.xml',
    '.\Subnet_0405.xml',
    '.\Switch_0405.xml',
    '.\WaP_0405.xml'
)

# testing mmulti import of files with Auto properties guess
$MyData = Read-TACData -Path $PathCSV

# Testing multi import of files with especified Properties
$MyData = Read-TACData -Path $PathCSV -Properties $Properties

# Smaller arrays for testing
$Properties = @(
    'Subnet',
    'Switch'
)

$PathCSV = @(
    '.\Subnet_0405.csv',
    '.\Switch_0405.csv'
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

# Testing missing entries on required columns
$MyValue =  Read-TACData -Path .\Subnet_MissingREntry.csv


# ---------------------------------------- Global Backup ----------------------------------------------------



$All_Properties_Exporters = @{
    CivicAddress = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $CivicAddress = Get-CsOnlineLisCivicAddress 
        if (-not $CivicAddress -or $CivicAddress.Count -eq 0) {
            Write-Verbose "No CivicAddress found in Teams Admin Center; skipping CivicAddress export."
            return
        }

        & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    LocationSchema = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $LocationSchema = Get-CsOnlineLisLocation
        if (-not $LocationSchema -or $LocationSchema.Count -eq 0) {
            Write-Verbose "No LocationSchema found in Teams Admin Center; skipping LocationSchema export."
            return
        }
        & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast
    
    }

    Subnet = { 
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Subnet = Get-CsOnlineLisSubnet
        if (-not $Subnet -or $Subnet.Count -eq 0) {
            Write-Verbose "No Subnet found in Teams Admin Center; skipping Subnet export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Switch = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Switch = Get-CsOnlineLisSwitch
        if (-not $Switch -or $Switch.Count -eq 0) {
            Write-Verbose "No Switch found in Teams Admin Center; skipping Switch export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Port = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Port = Get-CsOnlineLisPort
        if (-not $Port -or $Port.Count -eq 0) {
            Write-Verbose "No Port found in Teams Admin Center; skipping Port export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    WaP = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $WaP = Get-CsOnlineLisWirelessAccessPoint
        if (-not $WaP -or $WaP.Count -eq 0) {
            Write-Verbose "No WaP found in Teams Admin Center; skipping WaP export."
            return
        }

        & $Write_File -FolderPath $Path -Property $WaP -CSV:$CSV -XML:$XML -Fast:$Fast
    }
}

# Parammaters for file validation Extracted from Backup Files for MicrosoftTeams Powershell module Version 7.0.0
# item2 denotes if the property is required or not. If true, the property is required.
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

# Throttle limit for the number of threads to run in parallel. Should be equal to the number of properties in $All_Properties_Exporters*2
$ThrottleLimit = 12

#---------------------------------------- PRIVATE FUNCTION DEFINITIONS ----------------------------------------


$All_Properties_Exporters = @{
    CivicAddress = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $CivicAddress = Get-CsOnlineLisCivicAddress 
        if (-not $CivicAddress -or $CivicAddress.Count -eq 0) {
            Write-Verbose "No CivicAddress found in Teams Admin Center; skipping CivicAddress export."
            return
        }

        & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    LocationSchema = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast)

        $LocationSchema = Get-CsOnlineLisLocation
        if (-not $LocationSchema -or $LocationSchema.Count -eq 0) {
            Write-Verbose "No LocationSchema found in Teams Admin Center; skipping LocationSchema export."
            return
        }
        
        & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Subnet = { 
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Subnet = Get-CsOnlineLisSubnet
        if (-not $Subnet -or $Subnet.Count -eq 0) {
            Write-Verbose "No Subnet found in Teams Admin Center; skipping Subnet export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Switch = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Switch = Get-CsOnlineLisSwitch
        if (-not $Switch -or $Switch.Count -eq 0) {
            Write-Verbose "No Switch found in Teams Admin Center; skipping Switch export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Port = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $Port = Get-CsOnlineLisPort
        if (-not $Port -or $Port.Count -eq 0) {
            Write-Verbose "No Port found in Teams Admin Center; skipping Port export."
            return
        }

        & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    WaP = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast)

        $WaP = Get-CsOnlineLisWirelessAccessPoint
        if (-not $WaP -or $WaP.Count -eq 0) {
            Write-Verbose "No WaP found in Teams Admin Center; skipping WaP export."
            return
        }

        & $Write_File -FolderPath $Path -Property $WaP -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }
}