<#
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2024 Michael Rodrigues da Cunha

BackAtTAC is a free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

BackAtTAC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

To Load manifest information
$manifest = Import-PowerShellDataFile -Path '.\YourModuleName.psd1'
To Load this module do
Import-Module .\BackAtTAC.psd1
Get-Help BackUp-TACData -Full (or Read-TACData)
To unload Module do
Remove-Module BackAtTAC
To List Modules do
Get-Module
#>

@{
    RootModule           = 'BackAtTAC.psm1'
    ScriptsToProcess     = @('BackAtTAC_Globals')
    ModuleVersion        = '4.3'
    GUID                 = '0b3bc9ef-fc8a-4fbd-a0f2-cc8fd3ec7a92'
    Author               = 'Ferm1on'
    Description          = 'Teams Admin Center Backup Module'
    PowerShellVersion    = '5.1'
    FunctionsToExport    = @(
        'BackUp-TACData',
        'Read-TACData',
        'Reset-TACProperty',
        'Publish-TACProperty'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('Teams', 'Backup', 'Microsoft365')
            LicenseUri   = 'https://github.com/Ferm1on/BackAtTAC/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/Ferm1on/BackAtTAC'
        }
    }
}