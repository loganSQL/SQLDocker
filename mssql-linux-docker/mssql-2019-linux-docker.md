# MS SQL 2019 Linux Docker Note
## SQL Server Ubuntu Container
[SQL Server Ubuntu Container](<https://hub.docker.com/r/microsoft/mssql-server/>)

```
docker pull mcr.microsoft.com/mssql/server:vNext-CTP2.0-ubuntu
```
```
docker images
```
```
REPOSITORY                            TAG                   IMAGE ID            CREATED             SIZE
mcr.microsoft.com/mssql/server        vNext-CTP2.0-ubuntu   bc2f72b4310f        7 weeks ago         1.7GB
```
```
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Xmas2019' -p 1433:1433  --name UbuntuSQL2019 -d mcr.microsoft.com/mssql/server:vNext-CTP2.0-ubuntu

docker exec -it UbuntuSQL2019 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Xmas2019
```
```
1> select @@version
2> go
                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server vNext (CTP2.0) - 15.0.1000.34 (X64)
        Sep 18 2018 02:32:04
        Copyright (C) 2018 Microsoft Corporation
        Developer Edition (64-bit) on Linux (Ubuntu 16.04.5 LTS) <X64>                                                                                                     

(1 rows affected)
```

## SQL Server Red Hat Container 
[SQL Server Red Hat Container](<https://access.redhat.com/containers/#/mcr.microsoft.com/mssql/rhel/server>)
```
docker pull mcr.microsoft.com/mssql/rhel/server:2019-CTP2.1
```
```
docker images
```
```
REPOSITORY                            TAG                 IMAGE ID            CREATED             SIZE
mcr.microsoft.com/mssql/rhel/server   2019-CTP2.1         ae292d087222        6 days ago          1.98GB
```
```
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Xmas2019' -p 1433:1433  --name FirstSQL2019 -d mcr.microsoft.com/mssql/rhel/server:2019-CTP2.1
```
```
docker exec -it FirstSQL2019 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Xmas2019
1> select @@version,@@servername
2> go
                                                                                                                                                                                                                                                                                                                                                      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ --------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server 2019 (CTP2.1) - 15.0.1100.94 (X64)
        Nov  1 2018 14:35:49
        Copyright (C) 2018 Microsoft Corporation
        Developer Edition (64-bit) on Linux (Red Hat Enterprise Linux Server 7.6 (Maipo)) <X64>                                                                                           f32068c63e21

(1 rows affected)
```

