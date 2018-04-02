# Microsoft Dynamics NAV Docker on Windows
[Microsoft Dynamics NAV Docker on Windows](<https://hub.docker.com/r/microsoft/dynamics-nav/>)

## Docker Image and First NAV Container
    # Pull image
    docker pull microsoft/dynamics-nav:2018
    
    # Run Docker Image on Windows 10
    # First NAV docker container
    docker run -d -m 3G -e ACCEPT_EULA=Y -name FirstNAV microsoft/dynamics-nav


## First Container: FirstNAV2018 by NAVContainerHelper

    # PS as administrator
    Install-Module -Name navcontainerhelper
    #
    Write-NavContainerHelperWelcomeText
    #
    # To run your first NAV on Docker container. 
    # PowerShell a dialog for a username / a password to use for the container.
    New-NavContainer -accept_eula -containerName FirstNAV2018 -imageName "microsoft/dynamics-nav"

```
PS C:\logan\test> New-NavContainer -accept_eula -containerName FirstNAV2018 -imageName "microsoft/dynamics-nav"
Pulling docker Image microsoft/dynamics-nav:latest
latest: Pulling from microsoft/dynamics-nav
Digest: sha256:5cfa1637ceac87ede5f47ada42f7e97bb76689130aed7bd3d20117a94eda7572
Status: Downloaded newer image for microsoft/dynamics-nav:latest
Creating Nav container FirstNAV2018
Using image microsoft/dynamics-nav:latest
NAV Version: 11.0.20783.0-W1
Generic Tag: 0.0.5.5
Creating container FirstNAV2018 from image microsoft/dynamics-nav:latest
Waiting for container FirstNAV2018 to be ready
Initializing...
Starting Container
Hostname is FirstNAV2018
PublicDnsName is FirstNAV2018
Using Windows Authentication
Starting Local SQL Server
Starting Internet Information Server
Modifying Service Tier Config File with Instance Specific Settings
Starting NAV Service Tier
Creating DotNetCore NAV Web Server Instance
Creating http download site
Creating Windows user logan.sql
Setting SA Password and enabling SA
Creating SUPER user
Container IP Address: 172.31.11.188
Container Hostname  : FirstNAV2018
Container Dns Name  : FirstNAV2018
Web Client          : http://FirstNAV2018/NAV/
Dev. Server         : http://FirstNAV2018
Dev. ServerInstance : NAV

Files:
http://FirstNAV2018:8080/al-0.12.17720.vsix

Initialization took 80 seconds
Ready for connections!
Reading CustomSettings.config from FirstNAV2018
Creating Desktop Shortcuts for FirstNAV2018
Nav container FirstNAV2018 successfully created
```
```
PS C:\logan\test> docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS                    PORTS                                                NAMES
528f97c3c6f4        microsoft/dynamics-nav:latest   "powershell -Command…"   12 minutes ago      Up 11 minutes (healthy)   80/tcp, 443/tcp, 1433/tcp, 7045-7049/tcp, 8080/tcp   FirstNAV2018
```
```
PS C:\logan\test> sqlcmd -S FIRSTNAV2018 -E
1> select @@servername, @@version
2> go
                                                                                                                                                                                                                                                                                                                                                                                                                                    
-------------------------------------------------------------------------------------------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
F50071CBE75E\SQLEXPRESS                                                                                                          Microsoft SQL Server 2016 (SP1) (KB3182545) - 13.0.4001.0 (X64)
        Oct 28 2016 18:17:30
        Copyright (c) Microsoft Corporation
        Express Edition (64-bit) on Windows Server 2016 Datacenter 6.3 <X64> (Build 14393: ) (Hypervisor)


(1 rows affected)
1>
```
## Specify username and password for your NAV SUPER user 
    -e username=username -e password=password
    # Example (docker command line)
    docker run -e ACCEPT_EULA=Y -e username=admin -e password=P@ssword1 microsoft/dynamics-nav

## Setup Windows Authentication with the Windows User on the host computer
```
The parameters used to specify that you want to use Windows Authentication are:
-e auth=Windows -e username=username -e password=password
A container doesn’t have its own Active Directory, but you can still setup Windows Authentication by sharing your domain credentials to the container.
Example:
docker run -e ACCEPT_EULA=Y -e auth=Windows -e username=freddyk -e password=P@ssword1 microsoft/dynamics-nav
```

## Publishing ports on the host and specifying a hostname using NAT network settings
[Windows Container Networking](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-networking)

The parameters used for publishing ports on the host and specifying a hostname are not specific to the NAV container image, but are generic Docker parameters:

    -p <PortOnHost>:<PortInDocker> -h hostname

In order for a port to be published on the host, the port needs to be exposed in the container. By default, the NAV container image exposes the following ports:

    8080  file share
    80  http
    443  https
    1433  sql
    7045  management
    7046  client
    7047  soap
    7048  odata
    7049  development
If you want to publish all exposed ports on the host, you can use: 

    --publish-all or -P (capital P).
    
Note, publishing port 1433 on an internet host might cause your computer to be vulnerable for attacks.
Example:

    docker run -h test.nav.net -e ACCEPT_EULA=Y -p 8080:8080 -p 443:443 -p 7045-7049:7045-7049 microsoft/dynamics-nav
    
In this example, test.nav.net is a DNS name, which points to the IP address of the host computer (A or CNAME record) and the ports 8080, 443, 7045, 7046, 7047, 7048 and 7049 are all bound to the host computer, meaning that I can navigate to http://test.nav.net:8080 to download files from the NAV container file share.

## Place the Database file in a file share on the host computer
The database files are placed inside the container by default. If you want to copy the database to a share on the Docker host, you can override the SetupDatabase.ps1 script by creating a file called SetupDatabase.ps1 in c:\myfolder with this content:
```
if (!$restartingInstance) {
    $mdfName = Join-Path $PSScriptRoot "$DatabaseName.mdf"
    $ldfName = Join-Path $PSScriptRoot "$DatabaseName.ldf"
    $filesExists = (Test-Path $mdfName -PathType Leaf) -and (Test-Path $ldfName -PathType Leaf);
    Write-Host "Take database [$DatabaseName] offline"
    Invoke-SqlCmd -Query "ALTER DATABASE [$DatabaseName] SET OFFLINE WITH ROLLBACK IMMEDIATE"
    if ($filesExists) {
        Write-Host "Database files for [$DatabaseName] already exists"
    } else {
        Write-Host "Move database files for [$DatabaseName]"
        (Invoke-SqlCmd -Query "SELECT Physical_Name as filename FROM sys.master_files WHERE DB_NAME(database_id) = '$DatabaseName'").filename | ForEach-Object {
            $FileInfo = Get-Item -Path $_
            $DestinationFile = "{0}\{1}{2}" -f $PSScriptRoot, $DatabaseName, $FileInfo.Extension
            if (($DestinationFile -ne $mdfName) -and ($destinationFile -ne $ldfName)) { throw "Unexpected filename: $DestinationFile" }
            Copy-Item -Path $FileInfo.FullName -Destination $DestinationFile -Force
        }
    }
    Write-Host "Drop database [$DatabaseName]"
    Invoke-SqlCmd -Query "DROP DATABASE [$DatabaseName]"
    $Files = "(FILENAME = N'$mdfName'), (FILENAME = N'$ldfName')"
    Write-Host "Attach files as new Database [$DatabaseName]"
    Invoke-SqlCmd -Query "CREATE DATABASE [$DatabaseName] ON (FILENAME = N'$mdfName'), (FILENAME = N'$ldfName') FOR ATTACH"
} 
```
and then start a container with a command like this:
```
docker run -v c:\myfolder:c:\run\my -e ACCEPT_EULA=Y -e UseSSL=N microsoft/dynamics-nav:2017
```
Then you will see that database files will be copied to c:\myfolder unless they already exist. If the files already exists, they will be attached to the SQL Server in the Container. You can of course modify the script to fit your needs.

## Connect a NAV Container to another Database server
If you want to Connect NAV to another Database, which resides on a local SQL Server, you can do so by specifying DatabaseServer, DatabaseInstance and DatabaseName as parameters to Docker Run. This requires Windows Authentication (gMSA) to the SQL Server and needs to have setup SPN’s etc.
Example:
```
docker run --name navserver -h navserver -e accept_eula=Y -e usessl=N -e DatabaseServer=sqlserver -e DatabaseName=CRONUS microsoft/dynamics-nav:2017
```

## When developing and testing scripts
Create a PowerShell script like this:
```
$imageNameTag = "microsoft/dynamics-nav:2017"
docker rm navserver -f
docker pull $imageNameTag
docker run --name navserver `
           --hostname navserver `
           --volume c:\myfolder:c:\run\my `
           --env accept_eula=Y `
           --env usessl=N `
           --env username="vmadmin" `
           --env password="P@ssword1" `
           --env ExitOnerror=N `
           $imageNameTag
 ```
Modify your scripts in the shared folder (c:\myfolder) and run the above script to test
This enables you to have shortcuts to access WebClient, PowerShell prompts and other things as the URLs most likely will be the same.
It also allows you to quickly try your script with other version of NAV if that should be relevant.
And it is easy to add a line like

     --env ClickOnce=Y `

To enable ClickOnce. Or

     --env licensefile="c:\run\my\mylicense.flf" ` 

To use your own license file. Or

    --env auth=Windows `
 
To use Windows authentication, etc. etc.

## References
[NAV Docker Container Image](<https://github.com/loganSQL/SQLDocker/blob/master/microsoft-dynamicsNAV-docker/NAV%20Docker%20Image.docx>)

[Hands-On Lab: NAV on Docker](<https://github.com/loganSQL/SQLDocker/blob/master/microsoft-dynamicsNAV-docker/NAV%20on%20Docker%20HOL.docx>)

    
    
    