# BackAtTAC

## Project Description

**BackAtTAC** is a PowerShell module designed to automate the backup of Microsoft Teams Admin Center (TAC) configuration data, with a focus on **location-related information**. This module retrieves key Teams "Locations" data (such as emergency addresses, and network identifiers) and exports them to CSV or XML files for safekeeping. and save them as CSV and/or XML files. This provides an easy way to back up Teams settings that are not otherwise automatically saved, ensuring that important configuration (especially E911 location information) is preserved and can be restored or reviewed as needed.

BackAtTAC supports exporting data in both **CSV** and **XML** formats. The module also includes helper functions to read the exported files back into PowerShell objects, making it easy to verify or utilize the backed-up data. It is intended for **system administrators** who manage Microsoft Teams, particularly those responsible for Teams Phone and emergency location configurations.

## Features

- **Comprehensive Teams Location Backup** – Backs up Microsoft Teams Admin Center location-related configuration data, including:  
  - *CivicAddresses* – Emergency civic addresses (physical locations addresses)  
  - *Locations* – Defined locations (e.g. building/floor identifiers associated with addresses)  
  - *Subnets* – Network subnets mapped to locations (for location-based routing/E911)  
  - *Switches* – Network switches mapped to locations  
  - *Ports* – Switch ports mapped to locations  
  - *WirelessAccessPoints* – Wireless APs mapped to locations  

- **Multiple Export Formats** – Exports each data category to CSV and/or XML (Clixml) files. By default, both formats are generated for each category, with filenames following the pattern `<Property>_DDMM.csv` and `<Property>_DDMM.xml` (where `DDMM` is the current day and month).

- **Selective Backup** – Allows specifying particular properties to back up. You can choose to back up all supported data (default) or only a subset (e.g., only *CivicAddresses* and *Locations* if you are focused on those).

- **Parallel Processing for Speed** – An optional **Fast** mode uses multithreading to perform exports in parallel, which may speed up the backup in tenants with a large amount of data. (This requires PowerShell 7.5 or later; see **Prerequisites** below.) For smaller datasets, the default sequential mode may be just as fast or faster due to lower overhead.

- **Easy Data Retrieval** – Includes helper functions `Read-TACData` to quickly load the backed-up CSV or XML files back into PowerShell objects for review or restoration purposes.

## Prerequisites

Before using BackAtTAC, ensure you have the following:

- **PowerShell** – Windows PowerShell 5.1 **or** PowerShell 7.5.x.  
  - *Note:* The module is compatible with PowerShell 5.1 and above. However, to use the multi-threaded `-Fast` option, you need PowerShell 7.5 (or higher) where the ThreadJob capabilities are fully available. On Windows, it is recommended to use the latest PowerShell 7 release for best performance. This module has been tested on PowerShell 7.5.1

- **Microsoft Teams PowerShell Module** – The MicrosoftTeams module must be installed and available. BackAtTAC relies on cmdlets like `Get-CsOnlineLisLocation`, `Get-CsOnlineLisSubnet`, etc., which are provided by the Teams PowerShell module. If you don't have it installed, you can install it from the PowerShell Gallery by running:  
  ```powershell
  Install-Module -Name PowerShellGet -Force -AllowClobber
  Install-Module -Name MicrosoftTeams -Force -AllowClobber
  ```  
This module has been tested with MicrosoftTeams module version 6.9.0. You may find a Teams Powershell instalation guide here (https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-install)

- **Microsoft Teams Admin Permissions** – You must connect with an account that has the appropriate admin privileges (e.g., Teams Telephony Administrator or Global Administrator) to read Teams Admin Center data. The backup will only retrieve data that your account is authorized to access.

## Installation

Follow these steps to install the BackAtTAC module:

1. **Install Required Dependencies:** If not already done, install the Microsoft Teams PowerShell module (as shown above) and ensure you are running a supported PowerShell version. For example, on Windows you can use the latest [PowerShell 7.x](https://github.com/PowerShell/PowerShell) for full functionality.

2. **Obtain the BackAtTAC Module:** You have a couple of options:
   - **Manual Download:** Download or clone the BackAtTAC repository from GitHub. Then take the entire `BackAtTAC` folder (containing `BackAtTAC.psd1`, `BackAtTAC.psm1` and `BackAtTAC_Globals.ps1` files) and place it into one of your PowerShell module directories. Common locations are:  
     - `%USERPROFILE%\Documents\WindowsPowerShell\Modules\` (for Windows PowerShell 5.1 or for installing for only your user)  
     - `%USERPROFILE%\Documents\PowerShell\Modules\` (for PowerShell 7+ on Windows, user-scoped)  
     - `C:\Program Files\WindowsPowerShell\Modules\` (system-wide installation for all users in Windows PowerShell 5.1)  
     - `C:\Program Files\PowerShell\Modules\` (system-wide for PowerShell 7+).
     - You can find your module path with $env:PSModulePath
     Make sure the folder name is **BackAtTAC**, so that the module files are located at `BackAtTAC\BackAtTAC.psd1` etc. This ensures PowerShell can recognize the module.

3. **Import the Module:** Once the files are in place, import the BackAtTAC module into your PowerShell session:  
   ```powershell
   Import-Module BackAtTAC -Force
   ```  
   If the module was installed to a standard module path, you can also simply open a new PowerShell session and the module may auto-load when you call one of its commands. You can verify installation by running `Get-Module -ListAvailable BackAtTAC` to see if it's listed.

   Alternitavly you can simply place the **BackAtTAC.psd1**, **BackAtTAC.psm1** and **BackAtTAC_Globals.ps1** files in the same path you are running your backup script and dot source them.

Now you're ready to use BackAtTAC in your PowerShell environment.

## Usage

Before performing a backup, you should establish a connection to your Microsoft Teams environment. Use the MicrosoftTeams module's connect cmdlet to authenticate:

```powershell
Connect-MicrosoftTeams
```

This will prompt you to log in with your Microsoft 365 credentials (use an admin account with the needed Teams permissions). Once connected, you can use the BackAtTAC functions to backup data.

### Backing Up All Location Data

To back up **all supported Teams location data**, run the `BackUp-TACData` command with a target folder path. For example:

```powershell
BackUp-TACData -Path "C:\TACBackup"
```

This will retrieve **all** the location-related configurations from the Teams Admin Center (CivicAddresses, Locations, Subnets, Switches, Ports, WirelessAccessPoints) and export them to the folder **C:\TACBackup**. By default, for each category of data, two files will be created: one CSV file and one XML file. The files are named with the category and date, for example: `CivicAddresses_2104.csv` and `CivicAddresses_2104.xml` (if run on April 21), `Locations_2104.csv`, `Locations_2104.xml`, and so on. 

After running the command, you should find the backup files in the specified folder. Each CSV is a comma-separated list of the properties for that category, and each XML is an exported CLIXML representation of the same data (which can be imported back as objects in PowerShell if needed). The command will print verbose output indicating which categories are being exported, and it will skip any category that has no data in your tenant (e.g., if you have no defined Switches, it will note that and not create a file for Switches).

### Backing Up Specific Properties

In some cases, you might only want to back up a subset of the location information. The `BackUp-TACData` cmdlet accepts a `-Properties` parameter, which allows you to specify an array of one or more property names to export. For example, if you only care about emergency addresses and general location entries (and not the network mappings), you can run:

```powershell
BackUp-TACData -Path "C:\TACBackup" -Properties "CivicAddresses", "Locations" -CSV
```

This command will **only** export the *CivicAddresses* and *Locations* data, and it uses the `-CSV` switch to indicate that you only want CSV output. In this case, the module will create `CivicAddresses_2104.csv` and `Locations_2104.csv` in `C:\TACBackup` (no XML files, since we did not specify `-XML`). If you wanted only XML, you could use `-XML` instead, and if you omit both `-CSV` and `-XML`, it will default to creating both formats. You can list as many of the supported property names as needed after the `-Properties` parameter. (The property names are the same as listed in the **Features** section above.)

### Using Parallel (Fast) Backup Mode

For larger environments with thousands of entries, the backup process might take some time. BackAtTAC offers a **Fast mode** which runs the exports in parallel threads to speed up execution. To use this, you include the `-Fast` switch on the command. **Note:** The Fast mode option is only available when you run PowerShell 7.5 or later (it leverages the `Start-ThreadJob` feature). 

Example of using Fast mode for all data:

```powershell
BackUp-TACData -Path "C:\TACBackup" -Fast
```

With `-Fast` enabled, the module will spin up multiple background jobs to write the CSV and XML files concurrently for each category. It's recommended to use `-Fast` primarily when you expect a large volume of data in multiple categories. You may use Measure-Command{} to evaluate performance.

### Reading Back the Exported Data

The BackAtTAC module not only creates backups, but also provides an easy way to **read those backup files back into PowerShell** if you need to inspect or use the data. You may use the Read-TACData function to do this:

- **Read-TACData** – Use this to import a CSV or XML backup file. For example:  
  ```powershell
  $civicAddressData = Read-TACData -Path "C:\TACBackup\CivicAddresses_2104.csv"
  ```  
  This will read the CSV file and store the contents as an array of objects in the `$civicAddressData` variable. 

Read-TACData will automatically detect if the presented file is an CVS or XML file and what type of property it is based on the file name and import it. If you are using a non-standard file name, you may specify what is the property you are trying to load.

  ```powershell
  $civicAddressData = Read-TACData -Path "C:\TACBackup\CivicAddresses_2104.xml" -Properties 'CivicAddress'
  ``` 

Read-TACData can also be used to load multiple files at once by including an array of paths and an array of properties.

  ```powershell
      $PathCSV = @(
          '.\FooBar1_0405.csv',
          '.\FooBar2_0405.csv',
          '.\FooBar3_0405.csv',
          '.\FooBar4_0405.csv',
          '.\FooBar5_0405.csv'
      )

      $Properties = @(
      'CivicAddress',
      'LocationSchema',
      'Subnet',
      'Switch',
      'WAP'
      )

      $LoadedData = Read-TACData -Path $PathCSV -Properties $Properties
```
$LoadedData will be an array where each element corespond to a loaded property.

Read-TACData includes some error checking to ensure users load properties safely into their environment. For example, if an required attribute is missing in a loaded property the import will fail, if property and path arrays supplied are of different size, the import will also fail. Finally, you may pass a SHA256 checksum of the file to Read-TACData and the function will only import the property if the checksum matches.

  ```powershell
  $LoadedData = Read-TACData -Path $PathCSV -Properties $Properties -Checksum '45CCFE7398806E65605AB6264EDC4702A1882F32B0CBD9509772EF69A9275C61'
  ```

-Checksum may also be an array of checksums. Remember to make sure to order your input arrays correspond. That is, $PathCSV[i] → $Properties[i] → $Checksum[i].

### Uploading Data Back to Teams Admin Center

The BackAtTAC module also includes an easy way to publish data that was loaded into PowerShell using Read-TACData. You can use the Publish-TACProperty function to upload your backed-up data back into the Teams Admin Center.

**Publish-TACData** – Use this to upload data into the Teams Admin Center. For example:
  ```powershell
  # First load your backed up data.
  $LoadedData = Read-TACData -Path .\Port_0805.csv
  # Next, uploaded it to Teams Admin Center.
  Publish-TacProperty -Values $LoadedData -Property Port
  ```  
  This will upload all attribute-value pairs from $LoadedData and return a System.Object[] containing all the uploaded values as confirmation.

Publish-TACProperty includes error checking to ensure users upload properties safely to the Teams Admin Center (the same error checking as Read-TACData). For example, if a required attribute is missing from a loaded property, the publish will fail. You can use -Verbose to see the status of all checks when running the command.

Finally, -Confirm is also supported for extra safety.

## Contribution and Feedback

Contributions, suggestions, and feature requests for BackAtTAC are welcome! If you have an idea for supporting additional Teams Admin Center data (for example, if Microsoft introduces new location-related settings) or any improvements, please open an issue or submit a pull request on the GitHub repository. 

This project is maintained by the author (GitHub user **Ferm1on**), and I'll update it as time and interest allows.
"Dream of electric sheep."

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).