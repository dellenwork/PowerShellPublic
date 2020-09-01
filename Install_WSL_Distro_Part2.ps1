############## Downloading and installing the app ###################
$ErrorActionPreference = 'Continue'

# Set variables
$Default_Password = "password"
$DistroName = "wsl-debian-gnulinux"
#$DistroName = "wsl-ubuntu-1804"
$Distro = $DistroName.split("-")[1] #Split the name on dashes to use the 2nd element for the .exe
$Distro_URL = "https://aka.ms/" + $DistroName
$pkgpath = "c:\Users\Public\"
#$username = "student"  # Hard coded username to create path and user in the distro
$username = $env:UserName


############ Configure installed distro    #######################################
           
# set path
#$env:Path = $env:Path + ';c:\windows\system32'

# Set as the default distro
wslconfig /setdefault $Distro
write-host "installed default $?"

# Set WSL to V2 for better performance
wsl --set-default-version 2
write-host "installed version 2 $?"

# Create user  in Distro       -p $(echo $Default_password | openssl passwd -1 -stdin)
$MyCmd4 = "$Distro run useradd -g adm -d /home/$username -s /bin/bash  $username"
Invoke-Expression -Command $MyCmd4
write-host "installed user $?"

# set password
$StrUser = $username + ":" + $Default_Password
$MyCmd2 = $Distro + " run echo ""$StrUser"" | /usr/sbin/chpasswd"
Invoke-Expression -Command $MyCmd2
write-host "installed password $?"
#$SetPW = "$Distro run echo "D:password" | chpasswd"
#Invoke-Expression $SetPW

# Add user to distro Sudoers
$MyCmd5 = " $Distro run usermod -aG sudo $username "
Invoke-Expression -Command $MyCmd5
write-host "add to sudoers $?"



# Create user account, add to sudoer group for distro and set password
#$MyCmd = $Distro + " run adduser -m -s /bin/bash  -G sudo $username"
#Invoke-Expression -Command $MyCmd



#$Distro run $(echo $Default_password | passwd --stdin $username)



# Add code to refresh $Distro repo and get python packages
$cmd = "$Distro run apt-get -y update "
Invoke-expression $Cmd\
write-host "installed updates $?"

$cmd = "$Distro run  sudo apt-get -y Upgrade"
Invoke-expression $Cmd
if ($? -eq 0) {write-host "installed upgrades" }

#$Distro run sudo apt-get dist-upgrade
#$Distro run  sudo apt-get autoremove
#$Distro run  sudo apt-get install git-all
#$Distro -c  sudo apt-get install software-properties-common python-software-properties
# $Distro -c  sudo apt-get install python3


# Change default user in Distro
Invoke-Expression -Command "$Distro config --default-user $username"

"Done"
