#  Portainer: GUI for Docker Container Administration
# _05_Portainer.ps1
#	https://dbafromthecold.com/2017/03/01/a-gui-for-docker-container-administration/
docker search portainer

docker pull portainer/portainer

# verify that you can connect to the Docker Engine on the remote server from a powershell window on your local machine
# https://dbafromthecold.com/2017/02/22/remotely-administering-the-docker-engine-on-windows-server-2016/
docker --tlsverify `
  --tlscacert=$env:USERPROFILE\.docker\ca.pem `
  --tlscert=$env:USERPROFILE\.docker\server-cert.pem `
  --tlskey=$env:USERPROFILE\.docker\server-key.pem `
  -H=tcp://XX.XX.XX.XX:2375 images

docker images

# copy the certs into your C:\temp folder as the following script will copy them from that location into the container running Portainer.
copy-item $env:USERPROFILE\.docker\ca.pem C:\Temp
copy-item $env:USERPROFILE\.docker\server-cert.pem C:\Temp
copy-item $env:USERPROFILE\.docker\server-key.pem C:\Temp

# reate and run our Portainer container
docker run -d -p 9000:9000 --name portainer1 -vC:/temp:C:/temp portainer/portainer -H tcp://XX.XX.XX.XX:2375 --tlsverify --tlscacert=C:/temp\ca.pem --tlscert=C:/temp\server-cert.pem --tlskey=C:/temp\server-key.pem

# verified that the container is up and running you need to grab the private IP assigned to it
docker inspect portainer1

# private IP address assigned to the container I’ve built is 172.26.17.197 
# so I’ll enter http://172.26.17.197:9000 into my web browser
#
# Specify a password and then login. You will then see the Portainer dashboard