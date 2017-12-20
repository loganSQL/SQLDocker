#
# 01_SQL_Docker_Setup.ps1
#

<#
Steps to setup the first Microsoft SQL 2017 container and how to connect to it, start/stop, change instance name etc
https://hub.docker.com/r/microsoft/mssql-server-windows-developer/
#>

<####################
# First Container
####################>
# Find the images related to mssql
docker search microsoft/mssql

# Get the images if you want
docker pull microsoft/mssql-server-windows-developer

# What you have locally
docker images

# Just create a container
docker run -d -p 1433:1433 -e sa_password=Xmas2017 -e ACCEPT_EULA=Y --name FirstSQL2017 microsoft/mssql-server-windows-developer

# Inspect it
docker inspect FirstSQL2017 

docker ps

docker ps -a

docker images

<#################################################
# How to connect to SQL container in SSMS/ sqlcmd
#################################################>
# Get IPAddress for the container
docker inspect FirstSQL2017 | findstr 'IPAddress'

# 1) Connect it from SSMS from this local box by using the above container IP and sa/Xmas2017
# 2) Connect it using docker interactive and run sqlcmd with no user/pwd
docker exec -it FirstSQL2017 sqlcmd
# 3) Connect it using docker interactive and run sqlcmd with no user/pwd
docker exec -it FirstSQL2017 sqlcmd -S . -Usa -PXmas2017
# 4) Connect it from another host by using local hostname and sa/Xmas2017
hostname

<########################
-- Dig Further
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
sp_addserver 'FirstSQL2017','local'

# need to restart

# Get into container in powershell to restart SQL
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
docker exec -it FirstSQL2017 sqlcmd
# YES.
select @@servername

# Docker Log
docker logs -f FirstSQL2017

# To remove the container / image
docker stop FirstSQL2017
docker rm FirstSQL2017
