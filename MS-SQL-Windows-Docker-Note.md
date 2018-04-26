# MS SQL Docker Note
[Official Microsoft SQL Server Developer Edition images for Windows Containers](<https://hub.docker.com/r/microsoft/mssql-server-windows-developer/>)

## Download by Docker Pull
    docker pull microsoft/mssql-server-windows-developer
   
## Build Docker Container
    # host port 1533 => container port 1433
    # host file folder E:/databases/docker/ => container volume mounted C:/databases/
    docker run -d -p 1533:1433 -e sa_password=April2018 -e ACCEPT_EULA=Y -v E:/databases/docker/:C:/databases/ --name MYSQL2017 microsoft/mssql-server-windows-developer
    # for attached db
    #...-e attach_dbs="[{'dbName':'SampleDb','dbFiles':['C:\\databases\\sampledb.mdf','C:\\databases\\sampledb_log. ldf']}]"

## Test it
    # on host
    hostname
    docker ps
    docker inspect MYSQL2017
    docker exec -it MYSQL2017 sqlcmd
    docker exec -it MYSQL2017 powershell
    sqlcmd -Usa -S "localhost,1533"
    
    # on other machine
    sqlcmd -Usa -S "YourHost,1533"
    
## Administration
    docker start MYSQL2017
    docker stop MYSQL2017
    
[Active Directory Service Accounts for Windows Containers](<https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts>)