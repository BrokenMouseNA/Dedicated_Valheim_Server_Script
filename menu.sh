#!/bin/bash
# MAIN BRANCH MENU
#  THIS IS STILL A WORK IN PROGRESS BUT ALL THE FUNCTIONS WORK
#  I NEED TO JUST CLEAN IT UP AND FORMAT BETTER
#  PLEASE LET ME KNOW ABOUT ISSUES
#  UPDATE THE MENU BEFORE YOU USE IT 
# If Frankenstein was a bash script
# Please help improve this script
# Easy Valheim Server Menu
# Open to other commands that should be used... 
#If you want to buy me a beer: https://www.patreon.com/zerobandwidth
#Or send me VET coint: 0x6a2e7c13606e07d57664821a0d9920da75719c01
clear
###############################################################
#Only change this if you know what you are doing
#Valheim Server Install location(Default) 
worldpath=/opt/valheim/.config/unity3d/IronGate/Valheim/worlds
#Backup Directory ( Default )
backupPath=/opt/valheim/backups
###############################################################

# Set Menu Version
mversion="Version 1.6"
##
# Update Menu script 
##


##
# Admin Tools:
# -Backup World: Manual backups of .db and .fwl files
# -Restore World: Manual restore of .db and .fwl files
# -Stop Valheim Server: Stops the Valheim Service
# -Start Valheim Server: Starts the Valheim Service
# -Restart Valheim Server: Restarts the Valheim Service (stop/start)
# -Status Valheim Server: Displays the current status of the Valheim Server Service
# -Check and Apply Valheim Server Update: Reaches out to to Steam with steamcmd and looks for official updates. If found applies them and restarts Valheim services
# -Fresh Valheim Server: Installs Valheim server from official Steam repo. 
##

##
# Tech Support Tools
#Display Valheim Config File
#Display Valheim Server Service
#Display World Data Folder
#Display System Info
#Display Network Info
#Display Connected Players History
##

##
# Adding Valheim+ Mod Support
##


########################################################################
#############################Set COLOR VARS#############################
########################################################################

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
CLEAR='\e[0m'


##
# Color Functions
##
ColorRed(){
	echo -ne $RED$1$CLEAR
}
ColorGreen(){
	echo -ne $GREEN$1$CLEAR
}
ColorOrange(){
	echo -ne $ORANGE$1$CLEAR
}
ColorBlue(){
	echo -ne $BLUE$1$CLEAR
}
ColorPurple(){
	echo -ne $PURPLE$1$CLEAR
}
ColorCyan(){
	echo -ne $CYAN$1$CLEAR
}
ColorLightRed(){
	echo -ne $LIGHTRED$1$CLEAR
}
ColorLightGreen(){
	echo -ne $LIGHTGREEN$1$CLEAR
}
ColorYellow(){
	echo -ne $LIGHTYELLOW$1$CLEAR
}
ColorWhite(){
	echo -ne $WHITE$1$CLEAR
}

########################################################################
#####################Check for Menu Updates#############################
########################################################################

function script_check_update() {
BRANCH="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/tree/main"
    git stash
    LAST_UPDATE=`git show --no-notes --format=format:"%H" $BRANCH | head -n 1`
    LAST_COMMIT=`git show --no-notes --format=format:"%H" origin/$BRANCH | head -n 1`
        if [ $LAST_COMMIT != $LAST_UPDATE ]; then
   tput setaf 2; echo "Updating your branch $BRANCH" ; tput setaf 9; 
            git pull --no-edit
	  else
            echo "No updates available"

        fi
    echo "Resetting permissions on menu.sh"
    chmod +x menu.sh
    tput setaf 2; echo "Restarting menu system" ; tput setaf 9; 
    sleep 3
    ./menu.sh
}


########################################################################
########################Check of Valheim Updates########################
########################################################################

function valheim_update_check() {
#default install dir
valheiminstall=/opt/valheim/valheimserver/
#make temp directory for this Loki file dump
vaheiminstall_temp=/tmp/lokidump
loki_started=true

dltmpdir=vaheiminstall_temp
[ ! -d "$dltmpdir" ] && mkdir -p "$dltmpdir"

    logfile="$(mktemp)"
    echo "Update and Check Valheim Server"
    steamcmd +login anonymous +force_install_dir $valheiminstall_temp +app_update 896660 -validate +quit
    rsync -a --itemize-changes --delete --exclude server_exit.drp --exclude steamapps $valheiminstall_temp $valheiminstall | tee "$logfile"
    grep '^[*>]' "$logfile" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valheim Server was updated - restarting"
        systemctl restart valheimserver.service
    else
        echo "Valheim Server is already the latest version"
        if [ $loki_started = true ]; then
            systemctl start valheimserver.service
        fi
    fi
    loki_started=false
    rm -f "$logfile"

}

########################################################################
########################Install Valheim Server##########################
########################################################################

function valheim_server_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '--------------Install Valheim Server----------------')
$(ColorRed '----------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to INSTALL the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '----------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStartInstall
#if y, then continue, else cancel
        if [ "$confirmStartInstall" == "y" ]; then
    echo ""

    #check for updates and upgrade the system auto yes
    tput setaf 2; echo "Checking for upgrades" ; tput setaf 9;
    apt update && apt upgrade -y
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

tput setaf 2; echo "Install Git and Net-Tools" ; tput setaf 9;
apt install git net-tools -y
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#add multiverse repo
    tput setaf 2; echo "Adding multiverse REPO" ; tput setaf 9;
    add-apt-repository -y multiverse
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

#add i386 architecture
    tput setaf 1; echo "Adding i386 architecture" ; tput setaf 9;
    dpkg --add-architecture i386
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

#update system again
    tput setaf 1; echo "Checking and updating system again" ; tput setaf 9;
    apt update
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

# Linux Steam Local Account Password input
    echo ""
    clear
    echo "Thanks for downloading the script, let's get started"
    echo "The following information is required for configuration files"
    echo "Read each step carefully"
    echo "A printout of data entered will be displayed to you"
    echo ""
    echo "A non-root account will be created to run Valheim Server"
    echo "This account is named steam"
    while true; do
      echo "Password must be 5 Characters or more"
      echo "At least one number, one uppercase letter and one lowercase letter"
      tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
      tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
      echo ""
        read -p "Please give steam a password: " userpassword
            [[ ${#userpassword} -ge 5 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]] && break
      tput setaf 2; echo "Password not accepted - Too Short or has Special Characters" ; tput setaf 9;
      tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
    done
    clear
    echo ""
    # Take user input for Valheim Server Public Display
    echo ""
    echo "Enter a name for your Valheim Server"
    echo "This is for the Public Steam Browser Listing"
    read -p "Enter public server display name: " displayname
    echo ""
    clear
    # Take user input for Valheim Server World Database Generation
    echo ""
    echo "What do you want to call your in game world?"
    while true; do
        echo "Name must be 8 Characters or more"
        echo "No Special Characters not even a space"
	tput setaf 2;  echo "Good Example: ThorsHammer" ; tput setaf 9;
        tput setaf 1;  echo "Bad Example: Loki is a Trickster" ; tput setaf 9;
        read -p "Please make a world name: " worldname
            [[ ${#worldname} -ge 8 && "$worldname" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2;  echo "World Name not set: Too Short or has Special Characters" ; tput setaf 9; 
	tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
    done
    clear
    echo ""
    # Password for Server
    echo ""
    echo "Now for Loki, please follow instructions"
    echo "Your server is required to have a password"
    echo "Your password cannot match your public display name nor world name"
    echo "Make your password unique"
    tput setaf 2; echo "Your public display name: $displayname " ; tput setaf 9;
    tput setaf 2; echo "Your world name: $worldname " ; tput setaf 9;
    while true; do
    echo "This password must be 5 Characters or more"
    echo "At least one number, one uppercase letter and one lowercase letter"
    tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
    tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
    read -p "Enter Password to Enter your Valheim Server: " password
        [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]] && break
    tput setaf 2; echo "Password not accepted - Too Short, Special Characters" ; tput setaf 9; 
    tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
done
echo ""
cat >> /opt/valheim/serverSetup.txt <<EOF
Here is the information you entered
This information is for you to ref later, in case you forgot
---------------------------------------------------------------
nonroot steam password:  $userpassword
Public Server Name:      $displayname
Local World Name:        $worldname
Valheim Server Password: $password
---------------------------------------------------------------
Each time this is ran, the past info will be added to each line
---------------------------------------------------------------
EOF
chown steam:steam /opt/valheim/serverSetup.txt
clear
echo "Here is the information you entered"
echo "This information is saved in the valheim_server.sh file"
echo "This information is saved in /opt/valheim/serverSetup.txt for referance later, if you forget"
tput setaf 2; echo "---------------------------------------" ; tput setaf 9;
tput setaf 2; echo "nonroot steam password:  $userpassword " ; tput setaf 9;
tput setaf 2; echo "Public Server Name:      $displayname " ; tput setaf 9;
tput setaf 2; echo "Local World Name:        $worldname " ; tput setaf 9;
tput setaf 2; echo "Valheim Server Password: $password " ; tput setaf 9;
tput setaf 2; echo "---------------------------------------" ; tput setaf 9;
echo ""
sleep 5

#install steamcmd and libsd12-2
tput setaf 1; echo "Installing steamcmd and libsdl2"
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
apt install steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386 -y
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#EDIT HERE #1
#build account to run Valheim
tput setaf 1; echo "Building steam account NONROOT" ; tput setaf 9;
sleep 1
useradd --create-home --shell /bin/bash --password $userpassword steam
cp /etc/skel/.bashrc /opt/valheim/.bashrc
cp /etc/skel/.profile /opt/valheim/.profile
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build symbolic link for steamcmd
tput setaf 1; echo "Building symbolic link for steamcmd" ; tput setaf 9;
ln -s /usr/games/steamcmd /opt/valheim/steamcmd
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#chown steam user to steam
tput setaf 1; echo "Setting steam permissions" ; tput setaf 9;
chown -Rf steam:steam /opt/valheim/*
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#Download Valheim from steam
tput setaf 1; echo "Downloading and installing Valheim from Steam" ; tput setaf 9;
sleep 1
/opt/valheim/steamcmd +login anonymous +force_install_dir /opt/valheim/valheimserver +app_update 896660 validate +exit
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build config for start_valheim.sh
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9;  
tput setaf 1; echo "Building Valheim start_valheim server configuration" ; tput setaf 9;
rm /opt/valheim/valheimserver/start_valheim.sh
sleep 1
cat >> /opt/valheim/valheimserver/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${displayname}" -port 2456 -nographics -batchmode -world "${worldname}" -password "${password}"
export LD_LIBRARY_PATH=$templdpath
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build check log script
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building check log script" ; tput setaf 9;
rm /opt/valheim/check_log.sh
sleep 1
cat >> /opt/valheim/check_log.sh <<EOF
journalctl --unit=valheimserver --reverse
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#set execute permissions
tput setaf 1; echo "Setting execute permissions on start_valheim.sh" ; tput setaf 9;
chmod +x /opt/valheim/valheimserver/start_valheim.sh
tput setaf 2; echo "Done" ; tput setaf 9;
tput setaf 1; echo "Setting execute permissions on check_log.sh" ; tput setaf 9; 
chmod +x /opt/valheim/check_log.sh
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building systemctl instructions for Valheim" ; tput setaf 9; 
# remove old Valheim Server Service
rm /etc/systemd/system/valheimserver.service
# remove past Valheim Server Service
rm /lib/systemd/system/valheimserver.service
sleep 1
# Add new Valheim Server Service
# Thanks @QuadeHale
cat >> /lib/systemd/system/valheimserver.service <<EOF
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target
[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=/opt/valheim/steamcmd +login anonymous +force_install_dir /opt/valheim/valheimserver +app_update 896660 validate +exit
ExecStart=/opt/valheim/valheimserver/start_valheim.sh
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
WorkingDirectory=/opt/valheim/valheimserver
LimitNOFILE=100000
[Install]
WantedBy=multi-user.target
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#chown steam user permissions to all of user steam dir location
tput setaf 1; echo "Setting steam account permissions to /opt/valheim/*" ; tput setaf 9; 
chown steam:steam -Rf /opt/valheim/*
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

# Reload daemons
tput setaf 1; echo "Reloading daemons and spawning Necks" ; tput setaf 9; 
systemctl daemon-reload
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 1

# Start server
tput setaf 1; echo "By Thors Hammer we are Starting the Valheim Server" ; tput setaf 9; 
systemctl start valheimserver
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 1

# Enable server on restarts
tput setaf 1; echo "Enabling Valheim Server on start or after reboots" ; tput setaf 9; 
systemctl enable valheimserver
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 2
clear
tput setaf 2; echo "Check server status by typing systemctl status valheimserver.service"
tput setaf 2; echo "Thank you for using the script."
tput setaf 2; echo "Twitch: ZeroBandwidth"
tput setaf 2; echo "GLHF"
tput setaf 9;
echo ""
  
    echo ""    
    else
        echo "Canceling the INSTALL of Valheim Server Service - because Loki sucks"
fi
}

########################################################################
###################Backup World DB and FWL Files########################
########################################################################
function backup_world_data() {
    echo ""
    echo ""
         ## Get the current date as variable.
         TODAY="$(date +%Y-%m-%d-%X)"
	 echo "Checking to see if backup directory is created"
	 echo "If not, one will be created"
	 dldir=$backupPath
	 [ ! -d "$dldir" ] && mkdir -p "$dldir"
         sleep 1
         ## Clean up files older than 2 weeks. Create a new backup.
	 echo "Cleaning up old backup files. Older than 2 weeks"
         find $backupPath/* -mtime +14 -type f -delete
	 echo "Cleaned up better than Loki"
         sleep 1
         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ##--exclude some directories, for example the the browser's cache, `.bash_history`, etc.
	  #stop valheim server
         echo "Stopping Valheim Server for clean backups"
         systemctl stop valheimserver.service
         echo "Stopped"
	 echo "Making tar file of world data"
         tar czf $backupPath/valheim-backup-$TODAY.tgz $worldpath/*
	 echo "Process complete!"
	 sleep 1
	 echo "Restarting the best Valheim Server in the world"
         systemctl start valheimserver.service
         echo "Valheim Server Service Started"
	 echo ""
	 echo "Setting permissions for steam on backup file"
	 chown -Rf steam:steam /opt/valheim/backups
	 echo "Process complete!"
    echo ""

}

########################################################################
##################Restore World Files DB and FWL########################
########################################################################

# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {

#init empty array
    declare -a backups
#loop through backups and put in array
    for file in ${backupPath}/*.tgz
    do
        backups=(${backups[*]} "$file")
    done;
#counter index
    bIndex=1
    for item in "${backups[@]}";do
 #print option [index]> [file name]
        basefile=$(basename "$item")
         echo "$bIndex> ${basefile} "
#increment
    bIndex=$((bIndex+1))
    done
#promt user for index
tput setaf 2; echo "Select Backup File you wish to restore"  ; tput setaf 9;
    read -p "" selectedIndex
#show confirmation message


restorefile=$(basename "${backups[$selectedIndex-1]}")
echo -ne "
$(ColorRed '-----------------------------------------------')
$(ColorGreen 'Restore '${restorefile}' ?')
$(ColorGreen  'Are you sure you want to do this? ')
$(ColorOrange  'Remember to match world name with /opt/valheim/valheimserver/start_valheim.sh')
$(ColorOrange  'The param for -world "worldname" much match restore file worldname.db and worldname.fwl')
$(ColorGreen   'Press y(yes) or n(no)') "

#read user input confirmation
    read -p "" confirmBackup
#if y, then continue, else cancel
        if [ "$confirmBackup" == "y" ]; then
 #stop valheim server
        echo "Stopping Valheim Server"
        systemctl stop valheimserver.service
        echo "Stopped"
 #give it a few
        sleep 5
 #copy backup to worlds folder
        echo "Copying ${backups[$selectedIndex-1]} to ${worldpath}/"
        cp ${backups[$selectedIndex-1]} ${worldpath}/
 #untar
        echo "Unpacking ${worldpath}/${restorefile}"
        tar xzf ${worldpath}/${restorefile} --strip-components=7 --directory ${worldpath}/  
	chown -Rf steam:steam /opt/valheim/.config/unity3d/IronGate/Valheim/worlds/*
	#uncomment when test are 100%
	#last time steam was applied to /usr and other locations 
	#really jacked stuff up - DAMN IT LOKI!!!
	#chown -Rf steam:steam $worldpath
 #start valheim server
        echo "Starting Valheim Services"
        echo "This better work Loki!"
        systemctl start valheimserver.service
else
        echo "Canceling restore process because Loki sucks"
fi

}

########################################################################
########################Check of Valheim Updates########################
########################################################################


function check_apply_server_updates() {
    echo ""
    echo "Checking up Valheim Updates and Applying it"
    #Thanks to @lloesche for the throught process and function
    valheiminstall=/opt/valheim/valheimserver/
    #make temp directory for this Loki file dump
    vaheiminstall_temp=/tmp/lokidump
    loki_started=true

    dltmpdir=vaheiminstall_temp
    [ ! -d "$dltmpdir" ] && mkdir -p "$dltmpdir"

    logfile="$(mktemp)"
    echo "Update and Check Valheim Server"
    steamcmd +login anonymous +force_install_dir $valheiminstall_temp +app_update 896660 -validate +quit
    rsync -a --itemize-changes --delete --exclude server_exit.drp --exclude steamapps $valheiminstall_temp $valheiminstall | tee "$logfile"
    grep '^[*>]' "$logfile" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valheim Server was updated - restarting"
        systemctl restart valheimserver.service
    else
        echo "Valheim Server is already the latest version"
        if [ $loki_started = true ]; then
            systemctl start valheimserver.service
        fi
    fi
    loki_started=false
    rm -f "$logfile"

    echo ""

}

########################################################################
##############Verify Checking Updates for Valheim Server################
########################################################################

function confirm_check_apply_server_updates() {

while true; do
echo -ne "
$(ColorRed '-----------------------------------------------')"
echo ""
tput setaf 2; echo "WARNING DOING THIS WILL SHUTDOWN THE SERVER" ; tput setaf 9;
tput setaf 2; echo "MAKE SURE EVERYBODY IS LOGGED OUT OF THE SERVER" ; tput setaf 9;
tput setaf 2; echo "Press y(YES) and n(NO)" ; tput setaf 9;
tput setaf 2; read -p "Do you wish to continue?" yn ; tput setaf 9; 
echo -ne "
$(ColorRed '-----------------------------------------------')"
    case $yn in
        [Yy]* ) check_apply_server_updates; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}

########################################################################
###############Display Valheim Start Configuration######################
########################################################################

function display_start_valheim() {
    clear
    echo ""
    sudo cat /opt/valheim/valheimserver/start_valheim.sh
    echo ""

}

########################################################################
###############Display Valheim World Data Folder########################
########################################################################

function display_world_data_folder() {
    clear
    echo ""
    sudo ls -lisa $worldpath
    echo ""

}

########################################################################
######################Stop Valheim Server Service#######################
########################################################################


function stop_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '----------------Stop Valheim Server----------------')
$(ColorRed '----------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to STOP the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '----------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStop
#if y, then continue, else cancel
        if [ "$confirmStop" == "y" ]; then
    echo ""
    echo "Stopping Valheim Server Services"
    sudo systemctl stop valheimserver.service
    echo ""
    else
    echo "Canceling Stopping of Valheim Server Service - because Loki sucks"
    sleep 3
    clear
fi
}

########################################################################
###################Start Valheim Server Service#########################
########################################################################


function start_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '----------------Start Valheim Server----------------')
$(ColorRed '----------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to START the Valheim Server" ; tput setaf 9;
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9;
echo -ne "
$(ColorRed '----------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStart
#if y, then continue, else cancel
        if [ "$confirmStart" == "y" ]; then
    echo ""
    tput setaf 2; echo "Starting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9;
    sudo systemctl start valheimserver.service
    echo ""
    else
        echo "Canceling Starting of Valheim Server Service - because Loki sucks"
        sleep 3
    clear
fi
}

########################################################################
####################Restart Valheim Server Service######################
########################################################################

function restart_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '------------Restart Valheim Server----------------')
$(ColorRed '----------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to RESTART the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '----------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmRestart
#if y, then continue, else cancel
        if [ "$confirmRestart" == "y" ]; then
tput setaf 2; echo "Restarting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9; 
    sudo systemctl restart valheimserver.service
    echo ""
    else
        echo "Canceling Restarting of Valheim Server Service - because Loki sucks"
        sleep 3
    clear
fi
}

########################################################################
#####################Display Valheim Server Status######################
########################################################################

function display_valheim_server_status() {
    clear
    echo ""
    sudo systemctl status --no-pager -l valheimserver.service
    echo ""

}

########################################################################
##############Display Valheim Vanilla Configuration File################
########################################################################


function display_start_valheim() {
    clear
    echo ""
    sudo cat /opt/valheim/valheimserver/start_valheim.sh
    echo ""

}

########################################################################
#######################Sub Server Menu System###########################
########################################################################

server_install_menu(){
echo ""
echo -ne "
$(ColorOrange '-')$(ColorOrange '---------Server System Information--------')
$(ColorOrange '-')$(ColorGreen '1)') Fresh or Reinstall Valheim Server
$(ColorOrange '-')$(ColorGreen '0)') Go to Main Menu
$(ColorOrange '-------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) valheim_server_install ; server_install_menu ;;
           	    0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}
########################################################################
#########################Print System INFOS#############################
########################################################################


function display_system_info() {
clear
echo ""
    echo -e "-------------------------------System Information----------------------------"
    echo -e "Hostname:\t\t"`hostname`
    echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
    echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`
    echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
    echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
    echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`
    echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
    echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
    echo -e "Kernel:\t\t\t"`uname -r`
    echo -e "Architecture:\t\t"`arch`
    echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
    echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
    echo -e "System Main IP:\t\t"`hostname -I`
echo ""
    echo -e "-------------------------------CPU/Memory Usage------------------------------"
    echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "-------------------------------Disk Usage >80%-------------------------------"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""
}

########################################################################
#############################PRINT NETWORK INFO#########################
########################################################################

function display_network_info() {
clear
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""

}

########################################################################
################Display History of Connected Players####################
########################################################################

function display_player_history() {
clear
    echo ""
    sudo cat /var/log/syslog | grep ZDOID
    echo ""

}

########################################################################
#####################Sub Tech Support Menu System#######################
########################################################################

tech_support(){
echo ""
echo -ne "
$(ColorOrange '--------------Valheim Tech Support--------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Display Valheim Config File
$(ColorOrange '-')$(ColorGreen ' 2)') Display Valheim Server Service
$(ColorOrange '-')$(ColorGreen ' 3)') Display World Data Folder
$(ColorOrange '-')$(ColorGreen ' 4)') Display System Info
$(ColorOrange '-')$(ColorGreen ' 5)') Display Network Info
$(ColorOrange '-')$(ColorGreen ' 6)') Display Connected Players History
$(ColorOrange '-------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorOrange '-------------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) display_start_valheim ; tech_support ;; 
		2) display_valheim_server_status ; tech_support ;;
	        3) display_world_data_folder ; tech_support ;;
		4) display_system_info ; tech_support ;;
		5) display_network_info ; tech_support ;;
	        6) display_player_history ; tech_support ;;
		  0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

########################################################################
########################Sub Admin Menu System###########################
########################################################################

admin_tools_menu(){
echo ""
echo -ne "
$(ColorOrange '-------------Valheim Backup and Restore Tools---------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Backup World
$(ColorOrange '-')$(ColorGreen ' 2)') Restore World
$(ColorOrange '--------------------Valheim Service Tools-------------------')
$(ColorOrange '-')$(ColorGreen ' 3)') Stop Valheim Server
$(ColorOrange '-')$(ColorGreen ' 4)') Start Valheim Server
$(ColorOrange '-')$(ColorGreen ' 5)') Restart Valheim Server
$(ColorOrange '-')$(ColorGreen ' 6)') Status Valheim Server
$(ColorOrange '----------------Official Valheim Server Update--------------')
$(ColorOrange '-')$(ColorGreen ' 7)') Check and Apply Valheim Server Update
$(ColorOrange '------------------First Time or Reinstall-------------------')
$(ColorOrange '-')$(ColorGreen ' 8)') Fresh Valheim Server
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
		1) backup_world_data ; admin_tools_menu ;;
		2) restore_world_data ; admin_tools_menu ;;
		3) stop_valheim_server ; admin_tools_menu ;;
		4) start_valheim_server ; admin_tools_menu ;;
		5) restart_valheim_server ; admin_tools_menu ;;
		6) display_valheim_server_status ; admin_tools_menu ;;
		7) confirm_check_apply_server_updates ; admin_tools_menu ;;
		8) valheim_server_install ; admin_tools_menu ;;
		   0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

########################################################################
###################START VALHEIM PLUS MOD SECTION#######################
########################################################################



function install_mod_valheim_plus() {
clear
    echo ""
    echo "Install Valheim+"
    echo "Coming Soon"
    echo ""

}

function remove_mod_valheim_plus() {
clear
    echo ""
    echo "Remove Valheim+"
    echo "Coming Soon"
    echo ""

}

function update_valheim_plus() {
clear
    echo ""
    echo "Update Valheim+"
    echo "Coming Soon"
    echo ""

}

function valheim_plus_options() {
clear
    echo ""
    echo "Valheim+ Options"
    echo "Coming Soon"
    echo ""

}

########################################################################
######################START MOD SECTION AREAS###########################
########################################################################

function server_mods() {
    clear
    echo ""
    echo "Server Related Mods"
    echo "Coming Soon"
    echo ""

}

function player_mods() {
    clear
    echo ""
    echo "Player Related Mods"
    echo "Coming Soon"
    echo ""

}

function building_mods() {
    clear
    echo ""
    echo "Building Related Mods"
    echo "Coming Soon"
    echo ""

}

function other_mods() {
    clear
    echo ""
    echo "Other Related Mods"
    echo "Coming Soon"
    echo ""

}

########################################################################
######################END MOD SECTION AREAS###########################
########################################################################


valheim_plus_options(){
echo ""
echo -ne "
$(ColorRed '-------NOT ADDED YET BUILDING FRAME WORK---------')
$(ColorCyan '-------------Valheim+ Mod Menu---------------')
$(ColorCyan '-')$(ColorGreen ' 1)') Server Mods
$(ColorCyan '-')$(ColorGreen ' 2)') Player Mods
$(ColorCyan '-')$(ColorGreen ' 3)') Building Mods
$(ColorCyan '-')$(ColorGreen ' 4)') Other Mods
$(ColorCyan '------------------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Valheim+ Menu
$(ColorCyan '-')$(ColorGreen ' 00)') Go to Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
		1) server_mods ; valheim_plus_options ;;
		2) player_mods ; valheim_plus_options ;;
		3) building_mods ; valheim_plus_options ;;
		4) other_mods ; valheim_plus_options ;;
		   0) mods_menu ; menu ;;
		   00) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}


mods_menu(){
echo ""
echo -ne "
$(ColorCyan '-----------Valheim+ Install Remove Update----------')
$(ColorCyan '-')$(ColorGreen ' 1)') Install Valheim+ 
$(ColorCyan '-')$(ColorGreen ' 2)') Remove Valheim+ 
$(ColorCyan '-')$(ColorGreen ' 3)') Update Valheim+ 
$(ColorCyan '---------------Valheim+ Mod Menu-------------------')
$(ColorCyan '-')$(ColorGreen ' 4)') Valheim+ Options
$(ColorCyan '---------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
		1) install_mod_valheim_plus ; mods_menu ;;
		2) remove_mod_valheim_plus ; mods_menu ;;
		3) update_valheim_plus ; mods_menu ;;
		4) valheim_plus_options ; mods_menu ;;
		   0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}
########################################################################
##################FINISH VALHEIM PLUS MOD SECTION#######################
########################################################################




########################################################################
#######################Display Main Menu System#########################
########################################################################

menu(){
clear
echo ""
echo -ne "
$(ColorOrange '╔═════════════════════════════════════════╗')
$(ColorOrange '║~~~-ZeroBandwidths Easy Valheim Menu-~~~~║')
$(ColorOrange '╠═════════════════════════════════════════╝')
$(ColorOrange '║ Welcome Viking!') 
$(ColorOrange '║ open to improvement and small change for requiemzz')
$(ColorOrange '║ Beware Loki hides within this script')
$(ColorOrange '╚ ')${mversion} 
$(ColorOrange '----------Check for Script Updates---------')
$(ColorOrange '-')$(ColorGreen ' 1)') Check for Nimdy Script Updates
$(ColorOrange '-----------Valheim Server Commands---------')
$(ColorOrange '-')$(ColorGreen ' 2)') Server Admin Tools 
$(ColorOrange '-')$(ColorGreen ' 3)') Tech Support Tools
$(ColorOrange '-')$(ColorGreen ' 4)') Install Valheim Server
$(ColorOrange '-----------------Mods Menu-----------------')
$(ColorOrange '-')$(ColorGreen ' 5)') Coming Soon
$(ColorOrange '-------------------------------------------')
$(ColorGreen ' 0)') Exit
$(ColorOrange '-------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) admin_tools_menu ; menu ;;
		3) tech_support ; menu ;;
		4) server_install_menu ; menu ;;
		5) mods_menu ; menu ;;
		    0) exit 0 ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

# Call the menu function
menu
