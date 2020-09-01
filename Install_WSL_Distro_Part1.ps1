############## Downloading and installing the app ###################
$ErrorActionPreference = 'Continue'

# Enable wsl subsystems for linux (Must run in admin mode)
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Set Tls12 protocol to be able to download the wsl application
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set variables
$Default_Password = "password"
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

############## Initializing the wsl distro app without requiring user input ###################

# First define path to the installed distro
$Path1 = "/Users/"
$Path2 = "/AppData/Local/Microsoft/WindowsApps/" + $Distro + ".exe"
$hdd_name=(Get-WmiObject Win32_OperatingSystem).SystemDrive
[String] $distro_path = $hdd_name + $Path1 + $username + $Path2

# Install and set default user initially to root
$Option1 = " install --root"
$InstallCmd = $Distro + $Option1

#Set up a job so I can timeout the installer after a set period of time becuase the job will hang 
#waiting for input that is not provided.
$Job = Start-Job -ScriptBlock {
        Invoke-Command -ComputerName localhost -ScriptBlock {
        invoke-expression -Command $InstallCmd 
        } 
}
$Job | Wait-Job -Timeout 310
$Job | Stop-Job

# Cleanup after the install and remove installer
Remove-Item -path $FileToGet

############ Set up for part 2 after reboot    #######################################

# Set registry for RunOnce after reboot
$BaseURL = "https://raw.githubusercontent.com/dellenwork/PowerShellPublic/master/"
$ScriptName  = "Install_WSL_Distro_Part1.ps1"
$ScriptURL = $BaseURL + $ScriptName

$FileToSave = $PkgPath + $ScriptName


# Download WSL installer Scripts
Invoke-WebRequest -Uri $ScriptURL -OutFile $FileToSave

$ScriptName  = "Install_WSL_Distro_Part2.ps1"
$ScriptURL = $BaseURL + $ScriptName
Invoke-WebRequest -Uri $ScriptURL -OutFile $FileToSave

# set run once registry for reboot
$RunValue = "c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -noexit -command $FileToSave"
Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
Set-ItemProperty -Path . -Name InstallWSL -Value $FileToSave   

Restart-Computer  # WSL requires a reboot
