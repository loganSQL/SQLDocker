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
    start http://localhost:5000

### What is 'Docker for Windows'?
**Docker for Windows.exe** is basically a “manager app” the does several things:
* It sets up a “Hyper-V VM” named: MobyLinuxVM, which contains a minimal linux system, that is able to run docker containers.
* If you start your: Hyper-V Manager program, you’ll be able to see it.
* If started, it shows up at the bottom right app toolbar with the “Docker Moby Icon”

[Docker For Windows Forum](<https://forums.docker.com/c/docker-for-windows>)

[Run Linux and Windows Containers In Parallel](<https://stefanscherer.github.io/run-linux-and-windows-containers-on-windows-10/>)



