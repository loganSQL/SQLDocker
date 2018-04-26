# MS SQL Docker Note
[Official Microsoft SQL Server Developer Edition images for Windows Containers](<https://hub.docker.com/r/microsoft/mssql-server-windows-developer/>)

## Download by Docker Pull
    docker pull microsoft/mssql-server-windows-developer
   
## Build Docker Container
    # host port 1533 => container port 1433
    # host file folder E:/databases/docker/ => container volume mounted C:/databases/
    docker run -d -p 1533:1433 -e sa_password=April2018 -e ACCEPT_EULA=Y -v E:/databases/docker/:C:/databases/  -v E:/backup/docker/:C:/backup/ --name MSSQL2017 microsoft/mssql-server-windows-developer
    # for attached db
    #...-e attach_dbs="[{'dbName':'SampleDb','dbFiles':['C:\\databases\\sampledb.mdf','C:\\databases\\sampledb_log. ldf']}]"

## Test it
    # on host
    hostname
    docker ps
    docker inspect MSSQL2017
    docker exec -it MSSQL2017 sqlcmd
    docker exec -it MSSQL2017 powershell
    sqlcmd -Usa -S "localhost,1533"
    
    # on other machine
    sqlcmd -Usa -S "YourHost,1533"
    
## Administration
    docker start MSSQL2017
    docker stop MSSQL2017
    
## Change Default Databases / Backup Location
```
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', REG_SZ, N'C:\databases'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog', REG_SZ, N'C:\databases'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'C:\backup'
GO
```
    
[Active Directory Service Accounts for Windows Containers](<https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts>)