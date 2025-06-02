#---------------------------------------------- GLOBAL VARIABLES ----------------------------------------------

# All Supported properties that can be backed up. To add a new property...
#   1. Add a new function to $All_Properties_Exporters hashtable. 
#   2. Add new entry to $All_Properties_Parameters with proterty table schema and required fields.
#   3. Increase the throttle limit value by 2
$All_Properties_Exporters = @{
    CivicAddress = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $CivicAddress = Get-CsOnlineLisCivicAddress 

        if (-not $CivicAddress -or $CivicAddress.Count -eq 0) {
            Write-Verbose "No CivicAddress found in Teams Admin Center; skipping CivicAddress export."
            return
        } else {
            & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        }
    }

    LocationSchema = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $LocationSchema = Get-CsOnlineLisLocation

        if (-not $LocationSchema -or $LocationSchema.Count -eq 0) {
            Write-Verbose "No LocationSchema found in Teams Admin Center; skipping LocationSchema export."
            return
        } else {
            & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        }
    }

    Subnet = { 
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Subnet = Get-CsOnlineLisSubnet

        if (-not $Subnet -or $Subnet.Count -eq 0) {
            Write-Verbose "No Subnet found in Teams Admin Center; skipping Subnet export."
            return
        } else{
            & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } 
    }

    Switch = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Switch = Get-CsOnlineLisSwitch

        if (-not $Switch -or $Switch.Count -eq 0) {
            Write-Verbose "No Switch found in Teams Admin Center; skipping Switch export."
            return
        } else{
            & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } 
    }

    Port = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Port = Get-CsOnlineLisPort

        if (-not $Port -or $Port.Count -eq 0) {
            Write-Verbose "No Port found in Teams Admin Center; skipping Port export."
            return
        } else {
            & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        }
    }

    WaP = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $WaP = Get-CsOnlineLisWirelessAccessPoint

        if (-not $WaP -or $WaP.Count -eq 0) {
            Write-Verbose "No WaP found in Teams Admin Center; skipping WaP export."
            return
        } else {
            & $Write_File -FolderPath $Path -Property $WaP -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        }
    }
}

# Helper functons for deletion and upload of property data.
# item1 denotes Get function
# Item2 denotes Remove function
# Item3 denotes New funciton
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
            {param($CivicAddressId,$Location,$Elin=$null) 
                if($Elin){
                    New-CsOnlineLisLocation -CivicAddressId $CivicAddressId -Location $Location -Elin $Elin | OUT-NULL
                } else {
                    New-CsOnlineLisLocation -CivicAddressId $CivicAddressId -Location $Location | OUT-NULL
                }
            }
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
            {param($ChassisId,$LocationId, $Description) Set-CsOnlineLisSwitch -ChassisId $ChassisId -LocationId $LocationId -Description $Description}
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

# Parammaters for file validation Extracted from Backup Files for MicrosoftTeams Powershell module Version 7.0.0
# Item1 denotes the Property Attribute name.
# item2 denotes if the Attribute is required or not. If true, the Attribute is required for upload.
# item3 denotes if the attribute is a key or not. If true, the property is a key.
# item4 denotes the set of attributes used for uploading data to the cloud. If true, the attribute is used for upload.
$All_Properties_Parameters = @{

    CivicAddress = @(
        [System.Tuple[string,bool,bool,bool]]::New("AdditionalLocationInfo",  $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("City",                    $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("CityAlias",               $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("CivicAddressId",          $true,  $true,  $false)
        [System.Tuple[string,bool,bool,bool]]::New("CompanyName",             $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("CompanyTaxId",            $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Confidence",              $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CountryOrRegion",         $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("CountyOrDistrict",        $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("DefaultLocationId",       $true,  $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Elin",                    $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("HouseNumber",             $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("HouseNumberSuffix",       $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Latitude",                $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Longitude",               $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PartnerId",               $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PostDirectional",         $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("PostalCode",              $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("PreDirectional",          $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("StateOrProvince",         $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("StreetName",              $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("StreetSuffix",            $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("TenantId",                $true,  $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("ValidationStatus",        $false, $false, $false)
    )

    LocationSchema = @(
        [System.Tuple[string,bool,bool,bool]]::New("City",                    $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CityAlias",               $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CivicAddressId",          $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("CompanyName",             $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CompanyTaxId",            $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Confidence",              $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CountryOrRegion",         $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("CountyOrDistrict",        $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Elin",                    $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("HouseNumber",             $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("HouseNumberSuffix",       $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("IsDefault",               $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Latitude",                $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("Location",                $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("LocationId",              $false, $true , $false)
        [System.Tuple[string,bool,bool,bool]]::New("Longitude",               $flase, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("NumberOfTelephoneNumbers",$false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("NumberOfVoiceUsers",      $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PartnerId",               $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PostDirectional",         $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PostalCode",              $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("PreDirectional",          $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("StateOrProvince",         $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("StreetName",              $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("StreetSuffix",            $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("TenantId",                $false, $false, $false)
        [System.Tuple[string,bool,bool,bool]]::New("ValidationStatus",        $false, $false, $false)
    )

    Subnet = @(
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("LocationId",              $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Subnet",                  $true,  $true,  $true )
    )

    Switch = @(
        [System.Tuple[string,bool,bool,bool]]::New("ChassisId",               $true,  $true,  $true )
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("LocationId",              $true,  $false, $true )
    )

    Port = @(
        [System.Tuple[string,bool,bool,bool]]::New("PortID",                  $true,  $true,  $true )
        [System.Tuple[string,bool,bool,bool]]::New("ChassisID",               $true,  $true,  $true )
        [System.Tuple[string,bool,bool,bool]]::New("LocationId",              $true,  $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $true )
    )

    WaP = @(
        [System.Tuple[string,bool,bool,bool]]::New("Bssid",                   $true,  $true,  $true )
        [System.Tuple[string,bool,bool,bool]]::New("Description",             $false, $false, $true )
        [System.Tuple[string,bool,bool,bool]]::New("LocationId",              $true,  $false, $true )
    )
}

# Throttle limit for the number of threads to run in parallel. Should be equal to the number of properties in $All_Properties_Exporters*2
$ThrottleLimit = 12

#---------------------------------------- PRIVATE FUNCTION DEFINITIONS ----------------------------------------