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


#---------------------------------------- Function under construction ----------------------------------------

 # Clean up jobs and receive verbose output
 $Jobs | Wait-Job

 if($PSBoundParameters.ContainsKey('Verbose')) {
     foreach ($job in $Jobs) {
         "=== Job $($job.Id) Verbose Output ==="
         $job.Verbose # | ForEach-Object { "  $_" }
         $job | Receive-Job
     }
 } else {
     $jobs | Receive-Job
 }

 $jobs | Remove-Job