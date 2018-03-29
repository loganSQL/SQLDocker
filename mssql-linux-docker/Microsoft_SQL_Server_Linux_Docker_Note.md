# Microsoft SQL Server Linux Docker Note

## Pull image / Build Container
    # pull image
    docker version
    docker search microsoft/mssql
    docker pull microsoft/mssql-server-linux

    # start as a container FirstSQL2017
    docker run -d -p 1433:1433 -e 'SA_PASSWORD=Xmas2017' -e 'ACCEPT_EULA=Y' --name FirstSQL2017 microsoft/mssql-server-linux

    # inspect the running container
    docker inspect FirstSQL2017 | findstr 'IPAddress'

## Make Connection

### 1. Go to container directly
    # connect interactively using bash
    docker exec -it FirstSQL2017 bash
    
    # sqlcli on Linux (localhost inside container
    /opt/mssql-tools/bin/sqlcmd -S localhost -Usa

### 2. On windows host
    # get host name
    Hostname

    # open SSMS by using Hostname, SQL Login/pwd
    SSMS Hostname sa 
    
    # sqlcli on Windows
    sqlcmd -S $env:computername -Usa
    
### 3. WSL
    # check the sqlcmd path
    which sqlcmd
```/opt/mssql-tools/bin//sqlcmd
```
    # obviously localhost is working
    sqlcmd -Usa
    # or
    sqlcmd -S localhost -Usa

## Admin / Config on Linux

    # start container
    docker start FirstSQL2017 
    
    # stop container
    docker stop FirstSQL2017


    # enable HADR on Linux container in bash
    docker exec -it FirstSQL2017 bash
    mssql-conf set hadr.hadrenabled  1
    docker stop FirstSQL2017 


    # enable HADR on Windows Container in PS
    docker exec -it FirstSQL2017 powershell
    hostname
    service|findstr SQL
    Enable-SqlAlwaysOn -ServerInstance "6cdcf1e86ca8"
    docker stop FirstSQL2017 

## References
[SQL Server on Linux](<https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-overview>)
[Configure SQL Server on Linux with the mssql-conf tool](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-mssql-conf)