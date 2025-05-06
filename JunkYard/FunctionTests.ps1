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

# Working Space for new function.

function Reset-TACProperty {
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
    if (-not $All_Properties_Remove_Functions.ContainsKey($Property)) {
        Write-Error "This module does not support the cloud erasure of '$Property' property."
        return
    }

    #------------------------------------------- ERROR CHECKING END -------------------------------------------

    #--------------------------------------------- VARIABLES START --------------------------------------------

    # Build remove call function and parameters
    $tuple = $All_Properties_Remove_Functions[$Property]
    $Remove = $tuple.Item1
    $Arguments = @($tuple.Item2)
    if ($tuple.PSObject.Properties['Item3']) {
        $Arguments += $tuple.Item3
    }

    # Download property from TAC and exit if empty.
    $PropertyToErase = $All_Properties_Get_Functions[$Property].Invoke()
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

            if ($PSCmdlet.ShouldProcess("$Property Property", "Delete all $Property values from Teams Admin Center")) {
                
                # Build parameters
                $param = @{}
                foreach ($name in $Arguments) {$param[$name] = $Item.$name}

                # Log the item to be removed
                Add-Content -Path $LogFile -Value ($Item | Out-String)

                # Remove item
                & $Remove @param
            }
        }

            Write-Verbose "Property $Property has been reset from Teams Admin Center. All values have been removed."

    } else {
        
        foreach($Item in $PropertyToErase){

            if ($PSCmdlet.ShouldProcess("$Property Property", "Delete all $Property values from Teams Admin Center")) {
                
                # Build parameters
                $param = @{}
                foreach ($name in $Arguments) {$param[$name] = $Item.$name}

                # Remove item
                & $Remove @param
            }
        }

         Write-Verbose "Property $Property has been reset from Teams Admin Center. All values have been removed."      
    }
}

# ---------------------------------------- New Global Backup ----------------------------------------------------
$All_Properties_Get_Functions = @{

    CivicAddress = {Get-CsOnlineLisCivicAddress}

    LocationSchema ={Get-CsOnlineLisLocatio}

    Subnet = {Get-CsOnlineLisSubnet}
    
    Switch = {Get-CsOnlineLisSwitch}

    Port = {Get-CsOnlineLisPort}

    WaP = {Get-CsOnlineLisWirelessAccessPoint}
}

$All_Properties_Remove_Functions = @{

    CivicAddress = 
        [System.Tuple[scriptblock,string]]::New(
            {param($CivicAddressId)
                Remove-CsOnlineLisCivicAddress -CivicAddressId $CivicAddressId
            }, 
            'CivicAddressId')

    LocationSchema =
        [System.Tuple[scriptblock,string]]::New(
            {param($LocationId)
                Remove-CsOnlineLisLocation -LocationId $LocationId
            },
            'LocationId')

    Subnet =
        [System.Tuple[scriptblock,string]]::New(
            {param($Subnet)
                Remove-CsOnlineLisSubnet -Subnet $Subnet
            },
            'Subnet')
    
    Switch =
        [System.Tuple[scriptblock,string]]::New(
            {param($ChassisId)
                Remove-CsOnlineLisSwitch -ChassisId $ChassisId
            },
            'ChassisId')

    Port =
        [System.Tuple[scriptblock,string,string]]::New(
            { param($ChassisId, $PortId)
                Remove-CsOnlineLisPort -ChassisId $ChassisId -PortID $PortId
            }, 
            'ChassisId', 'PortId')

    WaP =
        [System.Tuple[scriptblock,string]]::New(
            {param($Bssid)
                Remove-CsOnlineLisWirelessAccessPoint -Bssid $Bssid
            },
            'Bssid')
}


$All_Properties_Functions = @{

    CivicAddress = 
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisCivicAddress},
            {param($CivicAddressId) Remove-CsOnlineLisCivicAddress -CivicAddressId $CivicAddressId}, 
            {New-CsOnlineLisCivicAddress})

    LocationSchema =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisLocatio}, 
            {param($LocationId) Remove-CsOnlineLisLocation -LocationId $LocationId}, 
            {New-CsOnlineLisLocatio})

    Subnet =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSubnet}, 
            {param($Subnet) Remove-CsOnlineLisSubnet -Subnet $Subnet},
            {New-CsOnlineLisSubnet})
    
    Switch =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisSwitch},
            {param($ChassisId) Remove-CsOnlineLisSwitch -ChassisId $ChassisId},
            {New-CsOnlineLisSwitch})

    Port =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisPort}, 
            { param($ChassisId, $PortId) Remove-CsOnlineLisPort -ChassisId $ChassisId -PortID $PortId}, 
            {New-CsOnlineLisPort})

    WaP =
        [System.Tuple[scriptblock,scriptblock,scriptblock]]::New(
            {Get-CsOnlineLisWirelessAccessPoint},
            {param($Bssid) Remove-CsOnlineLisWirelessAccessPoint -Bssid $Bssid},
            {New-CsOnlineLisWirelessAccessPoint})
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
        [System.Tuple[string,bool,bool]]::New("ChassisID",   $true,  $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
    )

    WaP = @(
        [System.Tuple[string,bool,bool]]::New("Bssid",       $true,  $true )
        [System.Tuple[string,bool,bool]]::New("Description", $false, $false)
        [System.Tuple[string,bool,bool]]::New("LocationId",  $true,  $false)
    )
}