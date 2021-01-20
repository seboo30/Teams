<#
.SYNOPSIS
Uninstall Teams from local app data and download machine wide installer

.DESCRIPTION
Use this script to remove and clear the Teams app from a computer. Run this PowerShell script for each user profile in which Teams was installed on the computer. After you run this script for all user profiles, Teams MAchine Wide installer will be downloaded and installed to program files
#>

$timestamp = Get-Date
$file = ([datetime]::UtcNow).tostring("yyyy_MM_dd").tostring() + ".msi"
$outpath = "C:\temp\teams-machine-wide-installer"+ $file
$url = "https://teams.microsoft.com/downloads/desktopurl?env=production"+"&"+"plat=windows"+"&"+"download=true"+"&"+"managedInstaller=true"+"&"+"arch=x64" 

Set-Location HKLM:\Software
New-Item HKLM:\SOFTWARE\Citrix
New-Item HKLM:\SOFTWARE\Citrix\PortICA

$TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsUpdateExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Microsoft", "Teams", "Update.exe")

if ([System.IO.File]::Exists($TeamsUpdateExePath))
    {
    Write-Host "Uninstalling Teams process"
    # Uninstall app
    $proc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru
    $proc.WaitForExit()
    }
Write-Host "Deleting Teams directory"
Remove-Item -path $TeamsPath -recurse

Start-Sleep -s 60

Invoke-WebRequest -Uri $url -OutFile $outpath

Start-Sleep -s 120
msiexec.exe /i $outpath /l*v TeamsLog.log ALLUSER=1

