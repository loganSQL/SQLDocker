#
# 01_SQL_Docker_Setup.ps1
#
<#
Steps to setup Microsoft SQL 2017 as a container and how to connect to it

The following are the references:

https://hub.docker.com/r/microsoft/mssql-server-windows-developer/
https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker
https://blogs.technet.microsoft.com/dataplatforminsider/2016/10/13/sql-server-2016-express-edition-in-windows-containers/
https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker
https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-docker

#>

<####################
--Step 1. Dockerfile
#####################>
FROM microsoft/dotnet-framework:4.7.1-windowsservercore-1709

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Add-WindowsFeature Web-Server; \
    Add-WindowsFeature NET-Framework-45-ASPNET; \
    Add-WindowsFeature Web-Asp-Net45; \
    Remove-Item -Recurse C:\inetpub\wwwroot\*

ADD ServiceMonitor.exe /

#download Roslyn nupkg and ngen the compiler binaries
RUN Invoke-WebRequest https://api.nuget.org/packages/microsoft.net.compilers.2.3.1.nupkg -OutFile c:\microsoft.net.compilers.2.3.1.zip ; \	
    Expand-Archive -Path c:\microsoft.net.compilers.2.3.1.zip -DestinationPath c:\RoslynCompilers ; \
    Remove-Item c:\microsoft.net.compilers.2.3.1.zip -Force ; \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe  | \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe  /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe ;

ENV ROSLYN_COMPILER_LOCATION c:\\RoslynCompilers\\tools

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]

<####################################################
-- Step 2 start a mssql server instance as container
####################################################>

docker run -d -p 1433:1433 -e Xmas2017 -e ACCEPT_EULA=Y microsoft/mssql-server-windows-developer

-- to get containerid, containername
docker ps

-- By default it starts as a random name, we rename the container
docker rename <DOCKER_CONTAINER_ID> logansql2017

-- to get the ip of container
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" logansql2017

<################################
-- Step 3 connect to SQL 2017
#################################>

# 3.1. Windows authentication using container administrator account
docker exec -it logansql2017 sqlcmd

# By default the sa is disable
# Enable it for the testing of the following test
#
alter login sa enable

-- 3.2. SQL authentication using the system administrator (SA) account
docker exec -it logansql2017 sqlcmd -S. -Usa

# create a user account with sa role
sp_helpsrvrole
sp_helpsrvrolemember 'sysadmin'
create login logansa with password="Xmas2017"
sp_addsrvrolemember @loginame='logansa',@rolename='sysadmin'

# disable sa again
alter login sa disable

# test the new login
docker exec -it logansql2017 sqlcmd -S. -Ulogansa

# 3.3. Connect from SSMS installed on the host
# get ip and port of container
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" logansql2017
docker ps

# SSMS container IP to connect , logansa

# 3.4. Connect from SSMS on another machine (other than the Host Environment)
#
# find out Container Host name or ip (not container ip!!!!)
#
ipconfig /all | findstr "Host Name"
ipconfig /all | findstr IPv4

# The port should be the same 1433
# In case of firewall rule, refer to https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-networking
#

# SSMS HOSTNAME or IP to connect , logansa

<########################
-- Step 4 Dig Further
#########################>
# From SSMS, Ooops, containerID
# Sadly, the instance property are still the container ID (Bug????)
select @@version

SELECT @@SERVERNAME,
    SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
    SERVERPROPERTY('MachineName'),
    SERVERPROPERTY('ServerName')

# to change the server instance name
# get the existing name
sp_helpserver

select @@servername

# drop my existing name
sp_dropserver '583046B12A82'

# add my new name
sp_addserver 'logansql2017','local'

# need to restart



# Get into container in powershell to restart SQL
docker exec -it logansql2017 powershell
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
docker stop logansql2017
docker start logansql2017
docker exec -it logansql2017 sqlcmd -S. -Ulogansa
# YES.
select @@servername


