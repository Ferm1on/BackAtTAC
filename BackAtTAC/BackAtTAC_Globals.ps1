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

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $CivicAddress -or $CivicAddress.Count -eq 0) {
            Write-Verbose "No CivicAddress found in Teams Admin Center; skipping CivicAddress export."
            return
        }

        if ($FastVerbose -and $Fast) {
            & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
        # & $Write_File -FolderPath $Path -Property $CivicAddress -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    LocationSchema = {
        [CmdletBinding()]
        param($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $LocationSchema = Get-CsOnlineLisLocation

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $LocationSchema -or $LocationSchema.Count -eq 0) {
            Write-Verbose "No LocationSchema found in Teams Admin Center; skipping LocationSchema export."
            return
        }
        
        if ($FastVerbose -and $Fast) {
            & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
        # & $Write_File -FolderPath $Path -Property $LocationSchema -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Subnet = { 
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Subnet = Get-CsOnlineLisSubnet

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $Subnet -or $Subnet.Count -eq 0) {
            Write-Verbose "No Subnet found in Teams Admin Center; skipping Subnet export."
            return
        }

        if($FastVerbose -and $Fast){
            & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
        # & $Write_File -FolderPath $Path -Property $Subnet -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Switch = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Switch = Get-CsOnlineLisSwitch

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $Switch -or $Switch.Count -eq 0) {
            Write-Verbose "No Switch found in Teams Admin Center; skipping Switch export."
            return
        }

        if($FastVerbose -and $Fast){
            & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
        # & $Write_File -FolderPath $Path -Property $Switch -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    Port = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $Port = Get-CsOnlineLisPort

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $Port -or $Port.Count -eq 0) {
            Write-Verbose "No Port found in Teams Admin Center; skipping Port export."
            return
        }

        if($FastVerbose -and $Fast){
            & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
        
        
        # & $Write_File -FolderPath $Path -Property $Port -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
    }

    WaP = {
        [CmdletBinding()]
        param ($Path, $Write_File, $CSV, $XML, $Fast, [Boolean]$FastVerbose)

        $WaP = Get-CsOnlineLisWirelessAccessPoint

        if ($FastVerbose) {
            $VerbosePreference = 'Continue'
        }

        if (-not $WaP -or $WaP.Count -eq 0) {
            Write-Verbose "No WaP found in Teams Admin Center; skipping WaP export."
            return
        }
        if($FastVerbose -and $Fast){
            & $Write_File -FolderPath $Path -Property $WaP -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$FastVerbose
        } else {
            & $Write_File -FolderPath $Path -Property $WaP -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$PSBoundParameters.ContainsKey('Verbose')
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

# Parammaters for file validation Extracted from Backup Files for MicrosoftTeams Powershell module Version 7.0.0
# Item1 denotes the Property Attribute name.
# item2 denotes if the Attribute is required or not. If true, the Attribute is required for upload.
# item3 denotes if the attribute is a key or not. If true, the property is a key.
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

# Throttle limit for the number of threads to run in parallel. Should be equal to the number of properties in $All_Properties_Exporters*2
$ThrottleLimit = 12

#---------------------------------------- PRIVATE FUNCTION DEFINITIONS ----------------------------------------