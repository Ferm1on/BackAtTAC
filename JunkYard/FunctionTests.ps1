# to Test Read-File and Read-TACData Function load the functions and BackAtTAC_Globals.psm1 variables file.
# You should also be in a directory with backed up files to load.

# Test Get-Help output works properly
Get-Help Read-TACData -Full

# Test simple load CSV CivicAddresses file.
$CivicA = Read-TACData -Path .\CivicAddress_1503.csv -PropertyType CivicAddress
$CivicA

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
