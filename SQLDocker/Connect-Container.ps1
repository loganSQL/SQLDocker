# Connect-Container.ps
<#
	Connect-Container
        By Logan SQL
	
	From host, connect to docker container by name directly using Admin Powershell ISE
	Examples:
		Connect-Container YourContainerName
#>
Function Connect-Container
{
Param(
	[parameter(ValueFromPipeline=$true)]
	[String]$myContainer
)
Process
    {
    #$myContainer="FirstSQL2017"
    $myName="name="+$myContainer
    $myId=Invoke-Command -ScriptBlock { param ($NameStr) docker ps --no-trunc -qf $NameStr } -ArgumentList $myName
    Enter-PSSession -ContainerId $myId
    }
}