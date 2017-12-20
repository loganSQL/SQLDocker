#
#	Create/copy/attach databases in a container images using sqlcmd scripting
#	02_Docker_Database.ps1
#


<#

1.	CREATE A DATABASE PRE-BUILT IMAGE VIA DOCKERFILE BY RUNNING SQLCmdScript.sql

#>

# need a folder to house the files I’ll be creating for my image. 
mkdir C:\logan\test\secondsql

#	create a startup script to run after instance created (sqlstartscript.sql)
#	any T-SQL will do (create login, database, objects etc)
create database logandb
go

use logandb
go

create table contact (name varchar(40), phone varchar(24), email varchar(50))
go

insert contact (name, phone, email) values ('Tom','416 5678890', 'tom.cry@gmail.com')
go

<#####################
# Dockerfile
######################>
FROM microsoft/mssql-server-windows-developer

# create directory within SQL container for database files
RUN powershell New-Item -ItemType directory -Path C:\\SQLServer

COPY sqlstartscript.sql C:\\SQLServer

# set environment variables
ENV SA_PASSWORD=Xmas2017
ENV ACCEPT_EULA=Y

RUN sqlcmd -i C:\\SQLServer\sqlstartscript.sqlh

<#####################
# Build the New Image
######################>
docker build -t secondsqlimage .

# Run the container
docker run -d  -p 1433:1433  --name secondsql secondsqlimage

<##################################################

2.	CREATE A DATABASE VIA DOCKERFILE BY USING COPY

####################################################>

# create some sample databases to local host dir

mkdir c:\logan\test\localdb

# Prepare database files for attached, from sqlcmd on local host
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

#	create a startup script to run after instance created (sqlstartscript.sql)
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


<#####################
# Dockerfile
######################>
FROM microsoft/mssql-server-windows-developer
 
# create directory within SQL container for database files
RUN powershell New-Item -ItemType directory -Path C:\\SQLServer
 
#copy the database files from host to container
COPY logandb1.mdf C:\\SQLServer
COPY logandb1_log.ldf C:\\SQLServer
 
COPY logandb2.mdf C:\\SQLServer
COPY logandb2_log.ldf C:\\SQLServer

COPY sqlstartscript.sql C:\\SQLServer
 
# set environment variables
ENV sa_password=Xmas2017
 
ENV ACCEPT_EULA=Y

RUN sqlcmd -i C:\\SQLServer\sqlstartscript.sql


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

