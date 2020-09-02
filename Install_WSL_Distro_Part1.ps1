############## Downloading and installing the app ###################
 Set-ExecutionPolicy Bypass -scope Process -Force
# Start-Process powershell -Verb runAs
$ErrorActionPreference = 'Continue'

# Enable wsl subsystems for linux (Must run in admin mode)
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart

# Set Tls12 protocol to be able to download the wsl application
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set variables
$DistroName = "wsl-debian-gnulinux"
#$DistroName = "wsl-ubuntu-1804"
$Distro = $DistroName.split("-")[1] #Split the name on dashes to use the 2nd element for the .exe
$Distro_URL = "https://aka.ms/" + $DistroName
$pkgpath = "c:\Users\Public\"
#$username = "student"  # Hard coded username to create path and user in the distro
$username = $env:UserName

# check to see if distro installation file exists or download the app otherwise
$FileToGet = $pkgpath + $Distro + ".appx"
if ( Test-Path $FileToGet -PathType leaf ) { "File already exists, deleting"
    # Cleanup after the install and remove installer
    Remove-Item -path $FileToGet }
# Download installer
(new-object System.Net.WebClient).DownloadFile($Distro_URL,$FileToGet) 

Write-Host "Starting appx install"
# Actually install the wsl distro app
$mycmd = "Add-AppxPackage " + $FileToGet 
invoke-expression -Command $mycmd
Write-Output "Installed $Distro : $?"


############ Set up for part 2 after reboot    #######################################

# Set registry for RunOnce after reboot
$ScriptName  = "Install_WSL_Distro_Part2.ps1"
$FileToSave = $PkgPath + $ScriptName

# set run once registry for reboot
$ItemPropertyValue = "powershell -file $FileToSave -Verb RunAs"
Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
Set-ItemProperty -Path . -Name InstallWSL -Value $ItemPropertyValue

Restart-Computer  # WSL requires a reboot
