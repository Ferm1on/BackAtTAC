# Next thing to try: Modify BackUp-Property to so that it can take as a imput a Scripblock of a helper function, in this case Write-File

function Write-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,

        [Parameter(Mandatory=$true)]
        [System.Object]$Property,

        [Parameter(Mandatory=$false)]
        [string]$FileName,

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

    # Generate FileName dynamically if not provided
    if (-not $FileName) {
        # Extract the type name after the last period
        $FullTypeName = ($Property | Select-Object -First 1).GetType().FullName
        if ($FullTypeName -match '([^\.]+)$') {
            $CapturedName = $Matches[1] -replace 'Response$', ''
        } else {
            $CapturedName = "ExportedData"
        }

        $FileName = "${CapturedName}_$((Get-Date).ToString('ddMM'))"
    }
    $FullFilePath = Join-Path -Path $FolderPath -ChildPath $FileName

    try {
        # Export the object to CSV
        if ($CSV -eq $XML) {
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

# Setup working variables and create directory
$Path = "TEST_$((Get-Date).ToString('ddMM'))"
New-Item -Path $Path -ItemType Directory -Force | Out-Null

$FileName = "TestFile_$((Get-Date).ToString('ddMM'))"

# Creating possible set of functions to run.
$All_Properties = @{
    Module = { 
        param($Path, $Write_File, $FileName, $CSV, $XML, $Fast)
        & $Write_File -FolderPath $Path -Property (Get-Module) -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Service = { 
        param($Path, $Write_File, $FileName, $CSV, $XML, $Fast)
        & $Write_File -FolderPath $Path -Property (Get-Service) -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast
    
    }

    PSDrive = { 
        param ($Path, $Write_File, $FileName, $CSV, $XML, $Fast)
        & $Write_File -FolderPath $Path -Property (Get-PSDrive) -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast
    }

    Process = { 
        param ($Path, $Write_File, $FileName, $CSV, $XML, $Fast)
        & $Write_File -FolderPath $Path -Property (Get-Process) -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast
    }
}

$CSV = $false
$XML = $false
$Fast = $false


Measure-Command {
    # Single Threaded processing of the functions
    foreach ($Property in $All_Properties.Values) {
        & $Property -Path $Path -Write_File $Write_File -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast
    }
}

Measure-Command {
    #Parrallel processing of the functions 
    $Jobs=@()
    foreach ($Property in $All_Properties.Values) {
        $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $FileName, $CSV, $XML, $Fast
    }
    $Jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
}

# ----------------------------------------------------------Notes-------------------------------------------------------------------

# Run all properties Paralle
foreach ($Property in $All_Properties.Values) {
    $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $FileName, $CSV, $XML, $Fast, $Verbose
}

# Rull All properties Sequentially
foreach ($Property in $All_Properties.Values) {
    & $Property -Path $Path -Write_File $Write_File -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$Verbose
}

# Error checking for properties list.
foreach ($Property in $Properties) {
    if (-not $All_Properties.ContainsKey($Property)) {
        Write-Error "This module does not support the backup of '$Property' property."
        return $False
    }
}

Measure-Command {
    # Single Threaded processing of the functions
    foreach ($Property in $All_Properties.Values) {
        & $Property -Path $Path -Write_File $Write_File -FileName $FileName -CSV:$CSV -XML:$XML -Fast:$Fast -Verbose:$Verbose
    }
}

<# 
Results for Single Threaded processing:

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 42
Milliseconds      : 550
Ticks             : 425508375
TotalDays         : 0.000492486545138889
TotalHours        : 0.0118196770833333
TotalMinutes      : 0.709180625
TotalSeconds      : 42.5508375
TotalMilliseconds : 42550.8375
#>

Measure-Command {
    #Parrallel processing of the functions 
    $Jobs=@()
    foreach ($Property in $All_Properties.Values) {
        $Jobs += Start-ThreadJob -ThrottleLimit 8 -ScriptBlock $Property -ArgumentList $Path, $Write_File, $FileName, $CSV, $XML, $Fast, $Verbose
    }
    $Jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
}

<#
# Results for Parallel processing:
Seconds           : 0
Milliseconds      : 8
Ticks             : 80426
TotalDays         : 9.30856481481482E-08
TotalHours        : 2.23405555555556E-06
TotalMinutes      : 0.000134043333333333
TotalSeconds      : 0.0080426
TotalMilliseconds : 8.0426
#>

<#
function BackUp-Property {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [System.Object]$Property,

        [Parameter(Mandatory=$true)]
        [scriptblock]$HelperFunction,

        [Parameter(Mandatory=$false)]
        [string]$FileName,

        [Parameter(Mandatory=$false)]
        [string[]]$Options=@()
    )

    if ($Property -and $Property.Count -gt 0) {
        & $HelperFunction -FolderPath $Path -Property $Property -FileName $FileName -Options $Options
    }
}
$BackUp_Property = [ScriptBlock]::Create((Get-Command BackUp-Property -CommandType Function).Definition)
#>