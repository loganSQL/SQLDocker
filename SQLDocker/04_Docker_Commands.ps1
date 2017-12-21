#	Some docker commands
# _04_Docker_Commands.ps1
#

# view container log
docker logs logansql2017
docker logs -f logansql2017

# export container images
# share a custom image in-house
# 1) where to store
cd c:\logan\test\images
# 2) Export
docker save -o logansql2017.tar logansql2017
# 3) Load
docker load -i logansql2017.tar

# Copying files from/to a container
docker exec -it logansql2017 powershell
cd "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\"
ls
exit
# 1) copy from container to local host
docker cp logansql2017:"C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\Summary.txt" C:\temp
# 2) copy from local host to container (do we need to docker stop ?)
docker cp C:\temp\test.txt logansql2017:C:\

# Automatically restarting Docker containers
#	Docker gives you the option of setting a restart policy for your containers with the following options: –
#		no: Never automatically restart (the default)
#		on-failure: Restart if there’s been an issue which isn’t critical
#		unless-stopped: Restart unless Docker stops or is explicitly stopped
#		always: Always restart unless explicitly stoppe
docker run -d -p 15789:1433 --restart always --env ACCEPT_EULA=Y --env SA_PASSWORD=Xmas2017 --name FirstSQL2017 microsoft/mssql-server-windows
docker ps

restart-computer -force

$wmi = Get-WmiObject -Class Win32_OperatingSystem
$wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime)
 
docker ps

# The docker kill command
# https://major.io/2010/03/18/sigterm-vs-sigkill/
docker stop logansql2017
docker kill logansql2017


