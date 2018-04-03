# Windows SQL Docker Note

[microsoft/mssql-server-windows-developer](https://hub.docker.com/r/microsoft/mssql-server-windows-developer/)

    # Pull image
    docker search microsoft/mssql
    docker pull microsoft/mssql-server-windows-developer

    docker images

    # create a window container
    docker run -d -p 1433:1433 -e sa_password=Xmas2017 -e ACCEPT_EULA=Y --name FirstSQL2017 microsoft/mssql-server-windows-developer

    # get info
    docker inspect FirstSQL2017 
    docker inspect FirstSQL2017 | findstr 'IPAddress'
    docker ps
    docker ps -a
    docker stats
    docker logs -f FirstSQL2017
    
    # start / stop
    docker stop FirstSQL2017
    docker start FirstSQL2017
    
    # connect to container
    docker exec -it FirstSQL2017 cmd
    ocker exec -it FirstSQL2017 powershell
    # 
    dir
    systeminfo
    sqlcmd
    get-service -name MSSQLServer
    #
    docker exec -it FirstSQL2017 sqlcmd
    docker exec -it FirstSQL2017 sqlcmd -S . -Usa -PXmas2017
    
    # from SQLCMD on host
    sqlcmd -Usa
    # or
    sqlcmd -S $env:computername -Usa
    
    # from SSMS
    HOSTNAME
    #
    echo $env:COMPUTERNAME
    
## Run ISE as Administrator like notepad.exe
    Enter-PSSession -ContainerId (docker ps --no-trunc -qf "name=FirstSQL2017")

    [4f8bf7c00997...]: PS C:\Users\ContainerUser\Documents>cd \
    [4f8bf7c00997...]: PS C:\> dir


    Directory: C:\


    Mode                LastWriteTime         Length Name                                                                                
    ----                -------------         ------ ----                                                                                
    d-----        7/16/2016   9:18 AM                PerfLogs                                                                            
    d-r---        1/16/2018   2:02 PM                Program Files                                                                       
    d-----         4/3/2018   1:34 PM                Program Files (x86)                                                                 
    d-r---        1/16/2018   2:02 PM                Users                                                                               
    d-----        1/16/2018   2:02 PM                Windows                                                                             
    -a----       11/22/2016   5:45 PM           1894 License.txt                                                                         
    -a----        1/16/2018   1:31 PM           2110 start.ps1
    
    # use psedit to edit an existing file
    [4f8bf7c00997...]: PS C:\> psedit start.ps1
    
    # create and edit a new file test.txt
    [4f8bf7c00997...]: PS C:\> echo ''>test.txt
    [4f8bf7c00997...]: PS C:\> dir 
                                                                           
    -a----         4/3/2018   2:08 PM              6 test.txt                                                                            
    
    
    
    [4f8bf7c00997...]: PS C:\> psedit test.txt
    
# [Connect-Container.ps1](<https://github.com/loganSQL/SQLDocker/blob/master/SQLDocker/Connect-Container.ps1>)
    <#
      Connect-Container
            By Logan SQL
      
      From host, connect to docker container by name directly using Admin Powershell ISE
      Examples:
        Connect-Container YourContainerName
    #>
    Function Connect-Container
    {
    Param(
      [parameter(ValueFromPipeline=$true)]
      [String]$myContainer
    )
    Process
        {
        #$myContainer="FirstSQL2017"
        $myName="name="+$myContainer
        $myId=Invoke-Command -ScriptBlock { param ($NameStr) docker ps --no-trunc -qf $NameStr } -ArgumentList $myName
        Enter-PSSession -ContainerId $myId
        }
    }
```    
PS C:\Windows\System32\WindowsPowerShell\v1.0> # Connect-Container.ps
Function Connect-Container
{
Param(
  [parameter(ValueFromPipeline=$true)]
  [String]$myContainer
)
Process
{
#$myContainer="FirstSQL2017"
$myName="name="+$myContainer
$myId=Invoke-Command -ScriptBlock { param ($NameStr) docker ps --no-trunc -qf $NameStr } -ArgumentList $myName
Enter-PSSession -ContainerId $myId
}
}

PS C:\Windows\System32\WindowsPowerShell\v1.0> Connect-Container FirstSQL2017

[4f8bf7c00997...]: PS C:\Users\ContainerUser\Documents> 
```
## Set MS SQL Servername (T-SQL)
    use master
    go
    
    select @@version
    go
    
    SELECT @@SERVERNAME,
        SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
        SERVERPROPERTY('MachineName'),
        SERVERPROPERTY('ServerName')
    go
    
    sp_helpserver
    go
    
    select @@servername
    go
    
    declare @myservername char(200)
    select @myservername=srvname from sysservers
    print @myservername
    exec sp_dropserver @myservername
    go
    
    exec sp_addserver 'FirstSQL2017','local'
    go
    
    sp_helpserver
    go

## Get into container in powershell to restart SQL
    docker exec -it FirstSQL2017 powershell
    dir
    get-service -name MSSQLServer
    
    cd C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\mssql
    
    net stop MSSQLServer
    net start MSSQLServer
    
    exit

# Now the server instance changes
    select @@servername
    sp_helpserver

# Does it persist when the container rebooted?
# Let's restart the container
    docker stop FirstSQL2017
    docker start FirstSQL2017
    sqlcmd -Usa
    # YES.
    select @@servername


# To remove the container / image
    docker stop FirstSQL2017
    docker rm FirstSQL2017
