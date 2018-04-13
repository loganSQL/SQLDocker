# Windows Server Docker EE Note
## [Install Docker EE](<https://docs.docker.com/install/windows/docker-ee/#about-docker-ee-containers-and-windows-server>)

    # Install docker-engine and docker cli client
    Install-Module DockerMsftProvider -Force
    Install-Package Docker -ProviderName DockerMsftProvider -Force
    
    # Check if a reboot is required, and if yes, restart your instance:
    (Install-WindowsFeature Containers).RestartNeeded
    
    # If the output of this command is Yes
    Restart-Computer
    
    # don't download any image first
    
## manage docker service
    # list all service 
    Get-WMIObject win32_service | Format-Table Name, StartMode -auto
    
    # list docker
    Get-WMIObject win32_service -Filter "name = 'docker'"
    
    # set to manual
    Set-Service -Name "docker" -StartupType manual
    
    # 
    Get-WMIObject win32_service -Filter "name = 'docker'"
    get-service docker
    stop-service docker
    start-service docker
    restart-service docker
    
    # get the path for docker service (daemon: dockerd.exe)
    gwmi win32_service|?{$_.name -eq "docker"}|select pathname
    pathname
    --------
    "C:\Program Files\Docker\dockerd.exe" --run-service
    
    # dockerd.exe (docker-engine)
    # docker.exe (docker cli client)
    cd "C:\Program Files\Docker
    
## Change Docker root location
    # Add file daemon.json
    cd C:\ProgramData\Docker\config
    notepad daemon.json
    {"graph": "E:\\ProgramData\\Docker"}
    
    # restart docker service
    restart-service docker
    get-service docker
    docker info
    
    # Or Docker daemon to use a different drive for storage with the -g dockerd.exe commandline option:
      -g, --graph string                          Root of the Docker runtime (default "C:\\ProgramData\\docker")
 
    
 ##

    # Test docker naoserver
    docker container run hello-world:nanoserver
    
    # or Test docker microsoft/windowsservercore
    docker run -it microsoft/windowsservercore powershell
    
