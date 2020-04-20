# escape=`
FROM compulim/msbuild AS builder
WORKDIR C:\src
COPY . .
RUN nuget restore .\NerdDinner\packages.config -PackagesDirectory .\packages
RUN msbuild .\NerdDinner\NerdDinner.csproj /p:OutputPath=c:\out\NerdDinner `
/p:DeployOnBuild=true `
/p:VSToolsPath=C:\MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3\tools\VSToolsPath


FROM mcr.microsoft.com/windows/servercore:ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
WORKDIR C:\nerd-dinner
RUN Remove-Website -Name 'Default Web Site'; `
New-Website -Name 'nerd-dinner' -Port 80 -PhysicalPath 'c:\nerd-dinner' -ApplicationPool '.NET v4.5'
RUN & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/handlers
COPY --from=builder C:\out\NerdDinner\_PublishedWebsites\NerdDinner C:\nerd-dinner

