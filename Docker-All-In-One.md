# Docker All In One
[CheatSheet](<https://www.cheatography.com/tobix10/cheat-sheets/docker-commands/>)

[Free ebook: Introduction to Windows Containers](<https://blogs.msdn.microsoft.com/microsoft_press/2017/08/30/free-ebook-introduction-to-windows-containers/>)

## Three Basic Commands
### docker build
 a declarative model in which a Dockerfile represents how to build a container, and the command runs on this file. The file contains at the start a from command that represents the base image to start from, and then it contains a series of commands that represent configuring the container and the underlying images. 
### docker compose
 a declarative service model in which multiple containers or build files represent a service; for example, a website in one container and a data store in another, which are always required. 
### docker run
 starts a container that is already built by either pulling from a central repository or locally. 

# Docker EcoSystem 
## Docker Hub

![Docker Hub](https://image.slidesharecdn.com/dockerecosystem1-160123214344/95/docker-ecosystem-engine-compose-machine-swarm-registry-11-638.jpg?cb=1453585459 "Docker Hub")

## Docker Architecture Layer

![Docker Architecture Layer](https://www.aquasec.com/wiki/download/attachments/2854889/Docker_Architecture.png?version=1&amp;modificationDate=1520172700553&amp;api=v2 "Docker Architecture Layer")

## Docker Architecture 

![Docker Architecture](https://image.slidesharecdn.com/dockerizingwindowsserverapplications-160629174623/95/dockerizing-windows-server-applications-by-ender-barillas-and-taylor-brown-8-638.jpg?cb=1467222665 "Docker Architecture")

## Docker Architecture on Windows / Linux
![Docker Architecture on Windows n Linux](http://storage.googleapis.com/xebia-blog/1/2017/03/windows-vs-linux-architecture1-1024x342.png "Docker Architecture on Windows n Linux")

# Docker Client

* The client docker.exe is located at C:\Program Files\Docker\
* docker help
* <https://docs.docker.com/engine/reference/commandline/cli/>

# Dockerfile

dockerfile

![dockerfile](https://www.sqlshack.com/wp-content/uploads/2017/04/word-image-60.png)

* <https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/manage-windows-dockerfile>
* [Example]<https://www.sqlshack.com/running-sql-server-containers-windows-server-2016-core/>

# Docker Compose
docker-compose.yml

![docker-compose.yml](https://copex.io/wp-content/uploads/2015/12/docker-compose.png)

* <https://docs.docker.com/compose/>
* [Example](<https://dbafromthecold.com/2017/07/12/creating-sql-server-containers-with-docker-compose/>)


# Container Hosts Preparation
## On a Windows Server 2016 with Desktop Experience
```
## Powershell Admin
Install-Module -Name DockerMSFTProvider -Repository PSGallery 
Install-Package -Name docker -ProviderName DockerMsftProvider 
start-Computer
```
## On a Windows Server 2016 Core 
```
sconfig 
Choosing option 6 : Download and Install Updates
All
... update and restart...
```
## On a Windows 10 (Professional / Enterprise)
```
Enable-WindowsOptionalFeature -Online -FeatureName Container -All 
Enable-WindowsOptionalFeautre -Online -FeatureName Microsoft-Hyper-V -All 
Restart-Computer

# Download Docker engine 
# Install Docker Engine and Client
```
## On a Nano Server 
Get an image from media

# Containers
## Deploying a base container image
Microsoft supplies two base images: 
• Server Core 
```
docker pull microsoft/iis:nanoserver
docker images
```
• Nano Server
```
docker pull microsoft/windowsservercore 
```

## Running a sample container
```
docker run microsoft/dotnet-samples:dotnetapp-nanoserver 
```

## Container Commands

### Help
```
docker <cmd> --help
```
### Container Lifecycle 
```
# Creates a container 
docker create 

# Renames a container
docker rename 

# Creates and runs a container 
docker run 

# Removes a container 
docker rm Removes a container 

# Updates a container resource limits
docker update
```

### Container Starting / Stopping
```
# Starts a container
docker start

# Stops a container 
docker stop 

# Stops and starts a container 
docker restart 

# Pauses a running container
docker pause  

# Unpause a running container 
docker unpause 

# Blocks until running container stops 
docker wait 

# Sends a SIGKILL to a container 
docker kill 

# Connects to a running container 
docker attach 
```

###  Container Resource constraints 
```
#
# commands available to limit resources
#
# Sets the container to 50% usage of the available CPU cores The value 512 specifies 50%, whereas changing the value to 1024 specifies 100%
#
docker run --ti -–c 512 < containername > 

#
# Sets the container to use a specific number of cores 
#
docker run –ti -cpusetcpus=0,1,2  

#
# Sets the container to have a memory limit 
#
docker run -it -m 300M < container >  
```

## Container information 
```
#  Shows the running containers 
docker ps

#  Gets logs from a container
docker logs 

# Looks at all the information on a container 
docker inspect

#  Gets event information from a container 
docker events

#  Shows the public-facing port of a container 
docker port

# Shows running processes in a container 
docker top

# Shows the resource usage statistics for a container 
docker stats

#  Shows changed files in the containers file systems
docker diff
```

### Images
```
#  Shows all the images on the container host
docker images 

#  Create an image from a Dockerfile 
docker build

#  Creates an image from a container
docker commit 

#  Remove an image from a container host
docker rmi 

#  Shows all the history of image
docker history 

#  Tags an image to a local host or registry
docker tag 

# Search the Docker Hub for an image 
docker search
```

### Network
```
# Creates a network for a container
docker network create 

# Removes a network 
docker network rm 

# Lists all networks
docker network ls 

# Display all info in relation to the network
docker network inspect

#  Connects a container to a network 
docker network connect

#  Disconnects a container from a network
docker network disconnect 
```