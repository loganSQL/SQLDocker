# Windows Containers Note
[Windows Containers Documentation](<https://docs.microsoft.com/en-us/virtualization/windowscontainers/index>)

## Two Types
* **Windows Server Containers** (share a kernel host)
* **Hyper-V Isolation** (each container is a VM)
## Windows Containers on Windows 10 (Hyper-V Isolation)
### First Container
    # 1. Install Docker for Windows (by default Linux container)
    # 2. Switch to Windows container 
    & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
    # 3. Install Base Container Images
    docker pull microsoft/nanoserver
    docker images
    docker run -it microsoft/nanoserver cmd
    powershell.exe Add-Content C:\helloworld.ps1 'Write-Host "Hello World"'
    exit
    docker ps -a
    # 4. Create a new image
    docker commit <containerid> helloworld
    docker images
    docker run --rm helloworld powershell c:\helloworld.ps1
### Sample App Container
    # 1. Application Source Code
    git clone https://github.com/cwilhit/SampleASPContainerApp.git
    # 2. Create the dockerfile for our proj
    New-Item C:/Your/Proj/Location/Dockerfile -type file
```
FROM microsoft/aspnetcore-build:1.1 AS build-env
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

FROM microsoft/aspnetcore:1.1
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "MvcMovie.dll"]
```
    # 3. Build
    docker build -t myasp .
    # 4. Run
    docker run -d -p 5000:80 --name myapp myasp
    docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" myapp
    # 5. go to browser