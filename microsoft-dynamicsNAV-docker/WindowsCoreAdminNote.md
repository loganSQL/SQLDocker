# Windows Server Core Administration

With a core server installation, you have a minimal UI that includes a limited desktop environment for local console management of the server. This minimal interface includes:

* Windows Logon screen for logging on and logging off
* Notepad for editing files
* Regedit for managing the registry
* Task Manager for managing tasks and starting new tasks
* Command Prompt for administration via the command line

## How to
After you log on to a core-server installation, you have a limited desktop environment with an Administrator command prompt. You can use this command prompt for administration of the server. If you accidentally close the command prompt, you can start a new command prompt by following these steps:

1. Press Ctrl+Shift+Esc to display Task Manager.
2. On the Applications tab, click New Task.
3. In the Create New Task dialog box, type cmd in the Open field and then click OK.

You can start Notepad and Regedit directly from a command prompt by entering **notepad**.exe or **regedit.exe** as appropriate. To open Control Panel, type **intl.cpl**.

## Additional Commands & Utilities

Here is an overview of key commands and utilities you’ll use for managing server core installations while logged on locally:

**Control desk.cpl** - View or set display settings.

**Control intl.cpl** - View or set regional and language options, including formats and the keyboard layout.

**Control sysdm.cpl** - View or set system properties.

**Control timedate.cpl** - View or set the date, time, and time zone.

**Cscript slmgr.vbs –ato** - Activate the operating system.

**DiskRaid.exe** - Configure software RAID.

**ipconfig /all** - List information about the computer’s IP address configuration.

**NetDom RenameComputer** - Set the server’s name and domain membership.

**OCList.exe** - List roles, role services, and features.

**OCSetup.exe** - Add or remove roles, role services, and features.

**PNPUtil.exe** - Install or update hardware device drivers.

**Sc query type=driver** - List installed device drivers.

**Scregedit.wsf** - Configure the operating system. Use the /cli parameter to list available configuration areas.

**ServerWerOptin.exe** - Configure Windows Error Reporting.

**SystemInfo** - List the system configuration details.

**WEVUtil.exe** - View and search event logs.

**Wmic datafile where name=“FullFilePath” get version**- List a file’s version.

**Wmic nicconfig index=9 call enabledhcp** - Set the computer to use dynamic IP addressing rather than static IP addressing.

**Wmic nicconfig index=9 call enablestatic(“IPAddress”), (“SubnetMask”)** - Set a computer’s static IP address and network mask.

**Wmic nicconfig index=9 call setgateways(“GatewayIPAddress”)** - Set or change the default gateway.

**Wmic product get name /value “** - List installed MSI applications by name.

**Wmic product where name=“Name” call uninstall** - Uninstall an MSI application.

**Wmic qfe list** - List installed updates and hotfixes.

**Wusa.exe PatchName.msu /quiet**- Apply an update or hotfix to the operating system.

## Docker Container Administration

### CMD

    docker exec -it FirstNAV2018 cmd

### Powershell

    docker exec -it FirstNAV2018 powershell

### Administrator Powershell ISE

    # Start Windows Powershell ISE as Administrator
    Enter-PSSession -ContainerId (docker ps --no-trunc -qf "name=FirstNAV2018")
    
    # or 
    Enter-NavContainer FirstNAV2018
    
    # Using ISE as an editor
    psedit yourfileinsidecontainer.ps1