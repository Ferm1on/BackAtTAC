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

# ---------------------------------------- New Global Backup ----------------------------------------------------

$All_Properties_Functions = @{

    CivicAddress = 
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisCivicAddress},
            {param($CivicAddressId) Remove-CsOnlineLisCivicAddress -CivicAddressId $CivicAddressId}, 
            {
                param($City)
                
                New-CsOnlineLisCivicAddress})

    LocationSchema =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisLocatio}, 
            {param($LocationId) Remove-CsOnlineLisLocation -LocationId $LocationId}, 
            {New-CsOnlineLisLocatio})

    Subnet =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSubnet}, 
            {param($Subnet) Remove-CsOnlineLisSubnet -Subnet $Subnet},
            {Set-CsOnlineLisSubnet})
    
    Switch =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSwitch},
            {param($ChassisId) Remove-CsOnlineLisSwitch -ChassisId $ChassisId},
            {Set-CsOnlineLisSwitch})

    Port =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisPort}, 
            { param($ChassisId, $PortId) Remove-CsOnlineLisPort -ChassisId $ChassisId -PortID $PortId}, 
            {Set-CsOnlineLisPort})

    WaP =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisWirelessAccessPoint},
            {param($Bssid) Remove-CsOnlineLisWirelessAccessPoint -Bssid $Bssid},
            {Set-CsOnlineLisWirelessAccessPoint})
}

$All_Properties_Parameters = @{

    CivicAddress = @(
        [System.Tuple[string,bool,bool]]::New("AdditionalLocationInfo",  $false, $false)
        [System.Tuple[string,bool,bool]]::New("City",                    $false, $false)
        [System.Tuple[string,bool,bool]]::New("CityAlias",               $false, $false)
        [System.Tuple[string,bool,bool]]::New("CivicAddressId",          $true,  $true )
        [System.Tuple[string,bool,bool]]::New("CompanyName",             $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CompanyTaxId",            $false, $false)
        [System.Tuple[string,bool,bool]]::New("Confidence",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("CountryOrRegion",         $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CountyOrDistrict",        $false, $false)
        [System.Tuple[string,bool,bool]]::New("DefaultLocationId",       $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false)
        [System.Tuple[string,bool,bool]]::New("Elin",                    $false, $false)
        [System.Tuple[string,bool,bool]]::New("HouseNumber",             $false, $false)
        [System.Tuple[string,bool,bool]]::New("HouseNumberSuffix",       $false, $false)
        [System.Tuple[string,bool,bool]]::New("Latitude",                $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Longitude",               $true,  $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false)
        [System.Tuple[string,bool,bool]]::New("PartnerId",               $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostDirectional",         $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostalCode",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("PreDirectional",          $false, $false)
        [System.Tuple[string,bool,bool]]::New("StateOrProvince",         $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetName",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetSuffix",            $false, $false)
        [System.Tuple[string,bool,bool]]::New("TenantId",                $true,  $false)
        [System.Tuple[string,bool,bool]]::New("ValidationStatus",        $false, $false)
    )

    LocationSchema = @(
        [System.Tuple[string,bool,bool]]::New("City",                    $false, $false)
        [System.Tuple[string,bool,bool]]::New("CityAlias",               $false, $false)
        [System.Tuple[string,bool,bool]]::New("CivicAddressId",          $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CompanyName",             $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CompanyTaxId",            $false, $false)
        [System.Tuple[string,bool,bool]]::New("Confidence",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("CountryOrRegion",         $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CountyOrDistrict",        $false, $false)
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false)
        [System.Tuple[string,bool,bool]]::New("Elin",                    $false, $false)
        [System.Tuple[string,bool,bool]]::New("HouseNumber",             $false, $false)
        [System.Tuple[string,bool,bool]]::New("HouseNumberSuffix",       $false, $false)
        [System.Tuple[string,bool,bool]]::New("IsDefault",               $false, $false)
        [System.Tuple[string,bool,bool]]::New("Latitude",                $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Location",                $false, $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $true )
        [System.Tuple[string,bool,bool]]::New("Longitude",               $true,  $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false)
        [System.Tuple[string,bool,bool]]::New("PartnerId",               $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostDirectional",         $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostalCode",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("PreDirectional",          $false, $false)
        [System.Tuple[string,bool,bool]]::New("StateOrProvince",         $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetName",              $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetSuffix",            $false, $false)
        [System.Tuple[string,bool,bool]]::New("TenantId",                $true,  $false)
        [System.Tuple[string,bool,bool]]::New("ValidationStatus",        $false, $false)
    )

    Subnet = @(
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Subnet",      $true,  $true )
    )

    Switch = @(
        [System.Tuple[string,bool,bool]]::New("ChassisId",   $true,  $true)
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
    )

    Port = @(
        [System.Tuple[string,bool,bool]]::New("PortID",      $true,  $true )
        [System.Tuple[string,bool,bool]]::New("ChassisID",   $true,  $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
    )

    WaP = @(
        [System.Tuple[string,bool,bool]]::New("Bssid",       $true,  $true )
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
    )
}

$All_Properties_Parameters = @{

    CivicAddress = @(
        [System.Tuple[string,bool,bool]]::New("AdditionalLocationInfo",  $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("City",                    $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("CityAlias",               $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("CivicAddressId",          $true,  $true,  $false)
        [System.Tuple[string,bool,bool]]::New("CompanyName",             $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("CompanyTaxId",            $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("Confidence",              $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("CountryOrRegion",         $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("CountyOrDistrict",        $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("DefaultLocationId",       $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("Elin",                    $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("HouseNumber",             $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("HouseNumberSuffix",       $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("Latitude",                $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("Longitude",               $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PartnerId",               $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostDirectional",         $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("PostalCode",              $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("PreDirectional",          $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("StateOrProvince",         $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("StreetName",              $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("StreetSuffix",            $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("TenantId",                $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("ValidationStatus",        $false, $false, $false)
    )

    LocationSchema = @(
        [System.Tuple[string,bool,bool]]::New("City",                    $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("CityAlias",               $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("CivicAddressId",          $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("CompanyName",             $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("CompanyTaxId",            $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("Confidence",              $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("CountryOrRegion",         $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("CountyOrDistrict",        $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("Elin",                    $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("HouseNumber",             $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("HouseNumberSuffix",       $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("IsDefault",               $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("Latitude",                $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("Location",                $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $true , $false)
        [System.Tuple[string,bool,bool]]::New("Longitude",               $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PartnerId",               $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostDirectional",         $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PostalCode",              $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("PreDirectional",          $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("StateOrProvince",         $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetName",              $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("StreetSuffix",            $false, $false, $false)
        [System.Tuple[string,bool,bool]]::New("TenantId",                $true,  $false, $false)
        [System.Tuple[string,bool,bool]]::New("ValidationStatus",        $false, $false, $false)
    )

    Subnet = @(
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("Subnet",                  $true,  $true,  $true )
    )

    Switch = @(
        [System.Tuple[string,bool,bool]]::New("ChassisId",               $true,  $true,  $true )
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $false, $true )
    )

    Port = @(
        [System.Tuple[string,bool,bool]]::New("PortID",                  $true,  $true,  $true )
        [System.Tuple[string,bool,bool]]::New("ChassisID",               $true,  $true,  $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $false, $true )
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $true )
    )

    WaP = @(
        [System.Tuple[string,bool,bool]]::New("Bssid",                   $true,  $true,  $true )
        [System.Tuple[string,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool]]::New("LocationId",              $true,  $false, $true )
    )
}

$All_Properties_Functions = @{
    CivicAddress =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisCivicAddress},
            {param($CivicAddressId) Remove-CsOnlineLisCivicAddress -CivicAddressId $CivicAddressId},
            {param($City,$CityAlias,$CompanyName,$CompanyTaxId,$CountryOrRegion,$Description,$Elin,$HouseNumber,$HouseNumberSuffix,$Latitude,$Longitude,$PostDirectional,$PostalCode,$PreDirectional,$StateOrProvince,$StreetName,$StreetSuffix) New-CsOnlineLisCivicAddress -City $City -CityAlias $CityAlias -CompanyName $CompanyName -CompanyTaxId $CompanyTaxId -CountryOrRegion $CountryOrRegion -Description $Description -Elin $Elin -HouseNumber $HouseNumber -HouseNumberSuffix $HouseNumberSuffix -Latitude $Latitude -Longitude $Longitude -PostDirectional $PostDirectional -PostalCode $PostalCode -PreDirectional $PreDirectional -StateOrProvince $StateOrProvince -StreetName $StreetName -StreetSuffix $StreetSuffix}
        )
    LocationSchema =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisLocation},
            {param($LocationId) Remove-CsOnlineLisLocation -LocationId $LocationId},
            {param($CivicAddressId,$Elin,$Location) New-CsOnlineLisLocation -CivicAddressId $CivicAddressId -Elin $Elin -Location $Location}
        )
    Subnet =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSubnet},
            {param($Subnet) Remove-CsOnlineLisSubnet -Subnet $Subnet},
            {param($Description,$LocationId,$Subnet) Set-CsOnlineLisSubnet -Description $Description -LocationId $LocationId -Subnet $Subnet}
        )
    Switch =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSwitch},
            {param($ChassisId) Remove-CsOnlineLisSwitch -ChassisId $ChassisId},
            {param($ChassisId,$Description,$LocationId) Setup-CsOnlineLisSwitch -ChassisId $ChassisId -Description $Description -LocationId $LocationId}
        )
    Port =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisPort},
            {param($ChassisId,$PortId) Remove-CsOnlineLisPort -ChassisId $ChassisId -PortID $PortId},
            {param($PortId,$ChassisId,$LocationId,$Description) Set-CsOnlineLisPort -PortId $PortId -ChassisId $ChassisId -LocationId $LocationId -Description $Description}
        )
    WaP =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisWirelessAccessPoint},
            {param($Bssid) Remove-CsOnlineLisWirelessAccessPoint -Bssid $Bssid},
            {param($Bssid,$Description,$LocationId) Set-CsOnlineLisWirelessAccessPoint -Bssid $Bssid -Description $Description -LocationId $LocationId}
        )
}


#---------------------------------------- Function under construction ----------------------------------------

function Publish-Property {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact        = 'High'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$Values,

        [Parameter(Mandatory = $true)]
        [string]$Property
    )

    # Do similar error checking as in Read-File function

    # Upload values to Teams Admin Center similarly to Reset-Property function
   
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
        $isArgument   = $tuple.Item4

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


# ----------------------------------------------------------------------------------------------------------------------
    # 3. Validate that all required attributes (Item2 = $true) are present and not empty
    $inputList = @($Values)  # ensure we have an array of objects (PROBLEMATIC)
    $missingAttrs = @()
    foreach ($tuple in $All_Properties_Parameters[$Property]) {
        if ($tuple.Item2) {
            foreach ($item in $inputList) {
                $val = $item.$($tuple.Item1)
                if ($null -eq $val -or ($val -is [string] -and [string]::IsNullOrEmpty($val))) {
                    if ($missingAttrs -notcontains $tuple.Item1) {
                        $missingAttrs += $tuple.Item1
                    }
                }
            }
        }
    }
    if ($missingAttrs.Count -gt 0) {
        Write-Error "Publish-Property: Required attribute(s) missing for '$Property': $($missingAttrs -join ', ')"
        return
    }
    # 4. Prepare the list of properties to include in the TAC call (Item4 = $true fields)
    $AddScript = $All_Properties_Functions[$Property].Item3
    $Arguments = @()
    foreach ($tuple in $All_Properties_Parameters[$Property]) {
        if ($tuple.Item4) {
            $Arguments += $tuple.Item1
        }
    }
    # 5. Iterate over each object and upload it to TAC
    $AddedItems = @()
    foreach ($item in $inputList) {
        if ($PSCmdlet.ShouldProcess("$Property property on Teams Admin Center", "Upload $($Arguments[0]) $($item.$($Arguments[0]))")) {
            # Build parameters for the TAC cmdlet call
            $param = @{}
            foreach ($name in $Arguments) {
                $param[$name] = $item.$name
            }
            # Invoke the TAC New/Set scriptblock with the parameters
            & $AddScript @param
            # Collect the uploaded item
            $AddedItems += $item
        }
    }
    # 6. Confirm completion with a verbose message and return the list of added items
    Write-Verbose "Property $Property has been published to Teams Admin Center. All provided values have been uploaded."
    return $AddedItem