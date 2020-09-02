############## Downloading and installing the app ###################
 # Start-Process powershell -Verb runAs
$ErrorActionPreference = 'Continue'

#http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String,$HashName = "MD5") 
{ 
$StringBuilder = New-Object System.Text.StringBuilder 
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
[Void]$StringBuilder.Append($_.ToString("x2")) 
} 
$StringBuilder.ToString() 
}

# Set variables
$NPassword = "password"
$DistroName = "wsl-debian-gnulinux"
#$DistroName = "wsl-ubuntu-1804"
$Distro = $DistroName.split("-")[1] #Split the name on dashes to use the 2nd element for the .exe
$Distro_URL = "https://aka.ms/" + $DistroName
$pkgpath = "c:\Users\Public\"
#$username = "student"  # Hard coded username to create path and user in the distro
$username = $env:UserName

############## Initializing the wsl distro app without requiring user input ###################

# First define path to the installed distro
$Path1 = "c:/Users/"
$Path2 = "/AppData/Local/Microsoft/WindowsApps/" + $Distro + ".exe"

[String] $distro_path = $Path1 + $username + $Path2

# Install and set default user initially to root
$Option1 = " install --root"
$InstallCmd = $Distro + $Option1
invoke-expression -Command $InstallCmd

#Set up a job so I can timeout the installer after a set period of time becuase the job will hang 
#waiting for input that is not provided.
#$Job = Start-Job -ScriptBlock {
#        Invoke-Command -ComputerName localhost -ScriptBlock {
#        invoke-expression -Command $InstallCmd 
#        } 
#}
#$Job | Wait-Job -Timeout 310
#$Job | Stop-Job

# Cleanup after the install and remove installer
#Remove-Item -path $FileToGet

############ Configure installed distro    #######################################

# Set as the default distro
wslconfig /setdefault $Distro
write-host "installed default $?"

# Set WSL to V2 for better performance
wsl --set-default-version 2
write-host "installed version 2 $?"

# Create user  in Distro 
$NewPassword = Get-StringHash($NPassword)
$MyCmd4 = "$Distro run useradd -G adm -d /home/$username -s /bin/bash -p $NewPassword $username"
Invoke-Expression -Command $MyCmd4
write-host "installed user $?"

# Add user to distro Sudoers
$MyCmd5 = " $Distro run usermod -aG sudo $username "
Invoke-Expression -Command $MyCmd5
write-host "add to sudoers $?"


# Add code to refresh $Distro repo and get python packages
$cmd = "$Distro run apt-get update "
Invoke-expression $Cmd
write-host "installed updates $?"

$cmd = "$Distro run  apt-get upgrade -y"
Invoke-expression $Cmd
if ($? -eq 0) {write-host "installed upgrades" }

$Cmd = "$Distro run apt-get dist-upgrade"
Invoke-expression $Cmd
$Cmd = "$Distro run  apt-get autoremove"
Invoke-expression $Cmd
$Cmd = "$Distro run apt-get install git-all -y"
Invoke-expression $Cmd
$Cmd = "$Distro run apt-get install software-properties-common  -y"
Invoke-expression $Cmd
$Cmd = "$Distro run apt-get install python3 -y"
Invoke-expression $Cmd

#change password for user in distro
$Cmd = "$Distro run 'echo "student:password" | chpasswd' "

# Change default user in Distro
Invoke-Expression -Command "$Distro config --default-user $username"

Write-Output "Done"
