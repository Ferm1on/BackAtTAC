# To Load manifest information
# $manifest = Import-PowerShellDataFile -Path '.\YourModuleName.psd1'
# To Load this module do
# Import-Module .\BackAtTAC.psd1
# Get-Help BackUp-TACData -Full (or Read-TACCSV' or 'Read-TACXML)
# To unload Module do
# Remove-Module BackAtTAC
# To List Modules do
# Get-Module

@{
    RootModule           = 'BackAtTAC.psm1'
    ModuleVersion        = '3.0'
    GUID                 = '0b3bc9ef-fc8a-4fbd-a0f2-cc8fd3ec7a92'
    Author               = 'Ferm1on'
    Description          = 'Teams Admin Center Backup Module'
    PowerShellVersion    = '5.1'
    FunctionsToExport    = @(
        'BackUp-TACData',
        'Read-TACCSV', 
        'Read-TACXML'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('Teams', 'Backup', 'Microsoft365')
            LicenseUri   = 'https://github.com/Ferm1on/Teams-Powershell-Backup-Module/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/Ferm1on/Teams-Powershell-Backup-Module'
        }
    }
}