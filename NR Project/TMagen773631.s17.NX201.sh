#!/bin/bash

	

	# The specific colors were providet after asking the deepseek
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
    
#starting to check if the programms installed

figlet 'Welcome Mr.Robot'


function installed ()
{
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
	echo 'Starting To Check For Tools'
	echo '----------------------------------'
	sleep 2
	for TOOL in geoiplookup nmap masscan figlet whois sshpass
	do
	CHECK=$(command -v $TOOL)
	if [ "CHECK" == "**" ]
	then
	echo -e ${RED}  'The $TOOL isnt installed Starting installation'${NC}
	sudo apt-get instal $TOOL -y &>/dev/null
	else
	echo -e ${GR}'The tool' $TOOL 'is installed' ${NC}
	echo 'Checking Complete'
	echo '-----------------------------------'
	fi
	done
	
}

	installed 
	
	function nipe_check ()
	{
		GR='\e[32m' #Printing in Green
		RED='\033[0;31m' #Printing echo in red
		NC='\033[0m'     #Ending printing in red and returning to no color
		echo 'Checking For Nipe'
		echo '------------------------------'
		sleep 2
		CHECK=$(locate nipe.pl)
		if [ -z "$CHECK" ] # the -z flag is like $CHECK == ** 
		then
		echo -e ${RED} 'The Nipe does not exist starting installation' ${NR}
		cd ; git clone https://github.com/htrgouvea/nipe && cd nipe
		sudo apt-get install cpanminus -y
		sudo cpanm --installdeps .
		sudo perl nipe.pl install 
		echo 'Install Complete!'
		echo '------------------------------'
		else
		echo -e ${GR}'The Nipe is installed' ${NC}
		echo 'Check Complete'
		echo '-------------------------------'
		sleep 2
		fi
	}
	nipe_check
	
	function ann_check () #checking if the nipe is on, if not turning it
{
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
    
	echo 'Checking if The Mask is on'
	EX_IP=$(curl -s ident.me)
	Country=$(geoiplookup $EX_IP | awk '{print $5}')
	echo "Your IP: $EX_IP | Country: $Country"
if [ $Country == 'Israel' ]
then
	echo -e ${RED} 'Youre Not annonymous, Put The mask on!' ${NC}
	NIPE_DIR=$(locate nipe| head -n 1)
	cd $NIPE_DIR
	sudo perl nipe.pl start
	sudo perl nipe.pl restart
	echo -e ${GR} 'Welcome Annonymous' ${NC}
	echo 'Your Ip Is'
	sudo perl nipe.pl status

else 
	echo -e ${GR} 'The Wolf mask is on! Youre Annonymous' ${NC}
	
	fi
	echo 'Returning Home'
	cd
}
ann_check

echo -e ${RED}LETS START HUNTING ${NC}

function Command_Control () #starting to connect to the victims ssh server
{
	
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
    
	echo 'Input The Sheep Home:'
	read -s IP_V4
	echo '------------------------------'
	echo 'Input The Sheep Name:'
	read -s U_Name
	echo '------------------------------'
	echo 'Input The Sheep Key:'
	read -s Pass
	echo '-----------------------------'
	if sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" exit 2>/dev/null; #Deep seek help with correct line, altho he gave the wrong code so 2 variables was deleted to make it work
	then
	echo -e ${GR}'Credentials Accepted' ${NC}
	echo -e ${GR} 'Saving Credentials of the sheep As Follows:' ${NC} 
	echo 'The Sheeps Home' $IP_V4 
	echo '------------------------------------'
	echo 'The Sheeps name' $U_Name
	echo '------------------------------------' 
	echo 'The Sheeps Key' $Pass 
	echo 'home' $IP_V4 >> sheep.txt
	echo 'name' $U_Name >> sheep.txt 
	echo 'key' $Pass >> sheep.txt 
	sleep 2
	echo -e ${RED} 'Saved in The Wolfs Den' ${NC}
	# Wolfs den = home/kali
	else 
	echo -e ${RED} 'Wrong Credentials, Try Again'${NC}
	Command_Control
	fi
}
	Command_Control
	function casetest () #menu of options wich scans/data youre interested in
{
	echo 'Choose info you want to see'
	echo '1. Sheeps Name' 
	echo '2. Sheeps Home' 
	echo '3. Sheeps External Home'
	echo '4. Sheeps Running time'
	echo '5. Sheeps Country'
	echo '6. Sheep Nmap '
	echo '7. Sheep Whois'
	echo '8. Exit'
	
	read Number

case $Number in 
	1) echo '-----------------------------------------------------------' 
	echo 'Sheeps name' $(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" whoami) | tee -a prey.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	2) echo '-----------------------------------------------------------'
	echo 'Sheeps Home is' $(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" hostname -I) | tee -a prey.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	3) echo '-----------------------------------------------------------' 
	echo 'Sheeps External Home is' $(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "curl -s ident.me") | tee -a prey.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	4) echo '-----------------------------------------------------------'
	echo 'Sheep Run Time' $(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "uptime") | tee -a prey.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	5) echo '-----------------------------------------------------------'
	echo 'The Sheeps Country is' $( sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "geoiplookup \$(curl -s ident.me) | awk '{print \$5}' " ) | tee -a prey.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	6) echo '-----------------------------------------------------------'
	function NMAP () #check for the tool on the victims machine
{
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
	echo 'Checking For Nmap on Remote host'
	echo '----------------------------------'
	sleep 2
	for NMAP in nmap
	do
	CHECK=$(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "command -v $NMAP")
	if [ "CHECK" == "**" ]
	then
	echo -e ${RED}  'The $NMAP isnt installed Starting installation'${NC}
	sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" sudo apt-get instal $NMAP -y &>/dev/null
	else
	echo -e ${GR}'The tool' $NMAP'is installed' ${NC}
	echo 'Checking Complete'
	echo '-----------------------------------'
	fi
	done
	
}
	NMAP
	echo 'Starting Nmap Scan, Enter desired destination:'
	read Scan
	echo 'Enter desired port:'
	read Port
	sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "nmap '$Scan' -p '$Port'"  | tee -a preynmap.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	7) echo '-----------------------------------------------------------'
		function WHOIS ()
{
	GR='\e[32m' #Printing in Green
	RED='\033[0;31m' #Printing echo in red
    NC='\033[0m'     #Ending printing in red and returning to no color
	echo 'Checking For Whois on Remote host'
	echo '----------------------------------'
	sleep 2
	for WHOIS in whois
	do
	CHECK=$(sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "command -v $WHOIS")
	if [ "CHECK" == "**" ]
	then
	echo -e ${RED}  'The $WHOIS isnt installed Starting installation'${NC}
	sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" sudo apt-get instal $WHOIS -y &>/dev/null
	else
	echo -e ${GR}'The tool' $WHOIS' is installed' ${NC}
	echo 'Checking Complete'
	echo '-----------------------------------'
	fi
	done
	
}
	WHOIS
	echo 'Starting Whois Scan, Enter Desired Destination:'
	read who
	sshpass -p "$Pass" ssh -o StrictHostKeyChecking=no "$U_Name@$IP_V4" "whois '$who'" | tee -a preywhois.txt
	echo '-----------------------------------------------------------'
	sleep 2
	casetest
	;;
	8) figlet 'Good Bye Master'
		echo -e ${RED}'The info saved into files in the Wolfs Den preywhois.txt preynmap.txt prey.txt and sheep.txt'
	;;
	*) echo 'Wrong Option Try Again'
	casetest
	;;
esac 

}	
casetest
