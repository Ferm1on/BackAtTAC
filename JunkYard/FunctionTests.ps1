# to Test Read-File and Read-TACData Function load the functions and BackAtTAC_Globals.psm1 variables file.
# You should also be in a directory with backed up files to load.

# Test Get-Help output works properly
Get-Help Read-TACData -Full

#----------------------------------------- Check CivicAddresses -----------------------------------------
# Test simple load CSV CivicAddresses file.
$CivicASum = (Get-FileHash -PAth .\CivicAddress_1503.csv -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress
$CivicA
# Test simple load CSV CivicAddresses with good checksum Validation
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicASum
# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Verbose
# Test verbose with good checksum
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicASum -Verbose
# Test Bad checksum
$CivicASum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicASum
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicASum -Verbose

# Test simple load Xml CivicAddresses file.
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -PropertyType CivicAddress
$CivicB
# Test simple load XML CivicAddresses with good checksum Validation
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -PropertyType CivicAddress -Checksum $CivicBSum
# Test verbose proper propagation.
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -PropertyType CivicAddress -Verbose
# Test verbose with good checksum
$CivicB = Read-TACData -Path .\CivicAddress_1503.xml -PropertyType CivicAddress -Checksum $CivicBSum -Verbose
# Test Bad checksum
$CivicBSum = (Get-FileHash -PAth .\CivicAddress_1503.xml -Algorithm SHA256).Hash
$CivicB = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicBSum
$CivicB = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Checksum $CivicBSum -Verbose

# Compare CVS and XML File
if (-not (Compare-Object $CivicA $CivicB)) {
    'Arrays are equal'
} else {
    'Arrays differ'
}
#----------------------------------------- Check CivicAddresses -----------------------------------------


# Test simple load CSV LocationSchemas file.
$LocationA = Read-TACData -Path .\LocationSchema_1503.csv -PropertyType LocationSchema
$LocationA

# Test simple load CSV Subnet file.
$SubnetA = Read-TACData -Path .\Subnet_1503.csv -PropertyType Subnet
$SubnetA

# Test simple load CSV Switch file.
$SwitchA = Read-TACData -Path .\Switch_1503.csv -PropertyType Switch
$SwitchA

# Test simple load CSV WAP file.
$WAPA = Read-TACData -Path .\Switch_1503.csv -PropertyType WAP
$WAPA


# Test verbose proper propagation.
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress -Verbose

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
