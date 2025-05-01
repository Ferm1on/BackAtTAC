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

    WaP = { 
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