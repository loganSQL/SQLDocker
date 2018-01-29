#
#  Docker Client Commands
#
#	Stop docker window service
service | findstr Docker
Stop-Service docker
stop-service com.docker.service

#
#	Start docker window service
#
"C:\Program Files\Docker\Docker\Docker for Windows.exe"
service | findstr Docker

docker version

#
#	Lifecycle: manage the lifecycle of a container
#
docker create 
docker rename
docker run
docker rm
docker update

#
#	Starting and stopping a container
#
docker start
docker stop
docker restart
docker pause
docker unpause
docker wait ##Block until running container stop
docker kill ##send SIGKILL to a container
docker attach  #Connect to a running container

#
#	Container resource constraints
#
<#
Set the container to 50% usage of the available CPU cores. 
The value 512 specifies 50% whereas changing the value to 1024 specifies 100%
#>
docker run --ti --c 512 <container Name> 
<#
Set the container to use a specific number of cores
#>
docker run --ti -cpuset-cpus=0,1,2
<#
Set the container to have a memory limit
#>
docker run --ti -m 300M <container Name>

#
#	Container information
#
docker ps
docker logs
docker inspect
docker events
docker port
docker top
docker stats
docker diff

#
#	Images
#
docker images
docker build
docker commit
docker rmi
docker history
docker tag
docker search

#
#	Network
#
docker network create
docker network rm
docker network ls
docker network inspect
docker network connect
docker network disconnect
