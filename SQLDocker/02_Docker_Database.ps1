#
#	Methods to create/copy/attach databases to container images
# 02_Docker_Database.ps1
#


<#
There are two flavors of SQL Server container images—­Linux-based images and Windows-based images. 

	https://hub.docker.com/search/?q=microsoft/mssql-server

	Microsoft provides a Linux-based image for SQL Server 2017 Developer Edition,
	and 
	three Windows-based images: 
	SQL Server 2016 SP1 Express Edition, 
	SQL Server 2016 SP1 Developer Edition 
	and SQL Server 2017 Evaluation Edition.

#>

<# Get Official Image:
Mac/Linux: sudo docker pull microsoft/mssql-server-linux
Windows: docker pull microsoft/mssql-server-windows
#>

#	microsoft/mssql-server-linux
#	microsoft/mssql-server-windows-developer
#	microsoft/mssql-server-windows-express
docker images

#	start container
#	-e: first time accept agreement
#	-p: mapping host port and container port
#	-d:	background (detach)
#	--name	name the container instance
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Xmas2017' -p 1433:1433 -d --name logansqllinux microsoft/mssql-server-linux
or
#	Windows
# docker run -d -p 1433:1433 -e Xmas2017 -e ACCEPT_EULA=Y --name logansql2017 microsoft/mssql-server-windows-developer
# docker start logansql2017

#	Interacting Directly with the SQL Server from the Command Line
#
#	On Linux
sqlcmd -S localhost -U sa  -P Xmas2017
#	On Windows
# docker exec -it logansql2017 sqlcmd -S. -Ulogansa

<#

1.	CREATE A DATABASE PRE-BUILT IMAGE VIA DOCKERFILE BY RUNNING SQLCmdScript.sql

#>

<################################
# how to create a dockerfile
#################################>
# need a folder to house the files I’ll be creating for my image. 
mkdir C:\logan\test

# There will be a total of four because I’m going to separate specific tasks into different files to keep things organized:

# 1.1. SqlCmdScript.Sql: This file will hold the TSQL script with the commands for creating the new database, table and data.

#	create database script
create database logandb
go

use logandb
go

create table contact (name varchar(40), phone varchar(24), email varchar(50))
go

insert contact (name, phone, email) values ('Tom','416 5678890', 'tom.cry@gmail.com')
go

# 1.2. SqlCmdStartup.sh: This is a bash file (like a batch file for Linux). It starts up the sqlcmd command-line tool and, as part of the command, runs the SqlCmdScript.Sql file. Remember that sqlcmd is also part of the base image.

#wait for the SQL Server to come up
sleep 20s
#run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Xmas -d master -i SqlCmdScript.sql 

# 1.3. Entrypoint.sh: This is another bash file. It lists the non-Docker tasks that need to run, 
#	and its first task is to execute the SqlCmdStartup.sh file. Then it will start the SQL Server process.
 
#start the script to create the DB and data then start the sqlserver
./SqlCmdStartup.sh & /opt/mssql/bin/sqlservr

<#
Notice that I’m running sqlcmd first. This is important and I struggled with this for a long time because of a misunderstanding. 
When Docker encounters a command that then completes, it stops the container. 
Originally, I ran the server startup first, then the sqlcmd. 
But when Docker finished the sqlcmd, it decided it had finished its job and shut down. 
In contrast, when I run the server startup second, the server is just a long-running process, 
therefore, Docker keeps the container running until something else tells it to stop.
#>

# 1.4. Dockerfile
FROM microsoft/mssql-server-linux
ENV SA_PASSWORD=Xmas2017
ENV ACCEPT_EULA=Y
COPY entrypoint.sh entrypoint.sh
COPY SqlCmdStartup.sh SqlCmdStartup.sh
COPY SqlCmdScript.sql SqlCmdScript.sql
RUN chmod +x ./SqlCmdStartup.sh
CMD /bin/bash ./entrypoint.sh

<#####################
# Build the New Image
######################>
docker build -t logansqllinuximage .

#

docker run -d  -p 1433:1433  --name logansqllinux logansqllinuximage

<##################################################

2.	CREATE A DATABASE VIA DOCKERFILE BY USING COPY

####################################################>

# create some sample databases to local host dir

mkdir c:\logan\test\localdb

# from sqlcmd on local host
CREATE DATABASE [logandb1] ON  PRIMARY 
( NAME = N'logandb1', FILENAME = N'c:\logan\test\localdb\logandb1.mdf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'logandb1_log', FILENAME = N'c:\logan\test\localdb\logandb1_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO

CREATE DATABASE [logandb2] ON  PRIMARY 
( NAME = N'logandb2', FILENAME = N'c:\logan\test\localdb\logandb2.mdf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'logandb2_log', FILENAME = N'c:\logan\test\localdb\logandb2_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO

EXEC master.dbo.sp_detach_db @dbname = N'logandb1'
GO
EXEC master.dbo.sp_detach_db @dbname = N'logandb2'
GO

# notepad Dockerfile
FROM microsoft/mssql-server-windows-developer
 
# create directory within SQL container for database files
RUN powershell New-Item -ItemType directory -Path C:\\SQLServer
 
#copy the database files from host to container
COPY logandb1.mdf C:\\SQLServer
COPY logandb1_log.ldf C:\\SQLServer
 
COPY logandb2.mdf C:\\SQLServer
COPY logandb2_log.ldf C:\\SQLServer
 
# set environment variables
ENV sa_password=Xmas2017
 
ENV ACCEPT_EULA=Y
# This one doesn't work 
# ENV attach_dbs="[{'dbName':'logandb1','dbFiles':['C:\\SQLServer\\logandb1.mdf','C:\\SQLServer\\logandb1_log.ldf']},{'dbName':'logandb2','dbFiles':['C:\\SQLServer\\logandb2.mdf','C:\\SQLServer\\logandb1_log.ldf']}]"

# 

# Build the image
docker build -t logandb .
# Start and Tag the image
docker run -d -p 1433:1433 --name logandb logandb

# Troubleshoot
docker logs -f 6522e32ba0ea

# connect to the container using powershell, and check the database files just copied.
docker exec -it logandb powershell
dir c:\SQLServer
# connect to the container using sqlcmd
docker exec -it logandb sqlcmd

# Attached the databses
EXEC sp_attach_db @dbname = N'logandb1', 
    @filename1 = 
N'C:\SQLServer\logandb1.mdf', 
    @filename2 = 
N'C:\SQLServer\logandb1_log.ldf'
go
EXEC sp_attach_db @dbname = N'logandb2', 
    @filename1 = 
N'C:\SQLServer\logandb2.mdf', 
    @filename2 = 
N'C:\SQLServer\logandb2_log.ldf'
go
select name rfom sys.databses
go

# HOUSEKEEP
docker ps
docker stop logandb

docker ps -a
docker rm 6522e32ba0ea

