#!/bin/bash

start=$(date +%s)

GR='\e[32m' #Printing in Green
RED='\033[0;31m' #Printing in Red
OR='\033[38;5;214m' #Printing in Orange
BLUE='\033[0;34m' #Printing in Blue
YELLOW='\033[1;33m' #Printing in Yellow
NC='\033[0m' # No Color

echo -e ${BLUE} 'Welcome To The Penetration Corps!' ${NC}
echo -e ${YELLOW} 'Starting the engines!' ${NC}

for TOOL in nmap searchsploit hydra xsltproc firefox
do 
	echo -e ${OR} "Checking For $TOOL" ${NC}
	if [ -z "$(which $TOOL  2>/dev/null)" ]
	then 
	echo -e ${RED} "[X] The $TOOL isnt installed!" ${NC}
	echo -e ${RED} "[!]Starting installation!" ${NC}
	sudo apt-get install $TOOL -y
	else
	echo -e ${GR} "[V] The $TOOL is installed,procceeding." ${NC}
	echo '------------------------------------------------------'
    fi
done

function validate_ip_range() 
{
    local range=$1
    if [[ $range =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]] 
    then
        local base_ip="${range%-*}"
        local end_part="${range#*-}"
        
        # Validate base IP
        if ! validate_ip_regex "$base_ip"
        then
            return 1
        fi
        
        # Get the last octet of base IP
        local last_octet=$(echo "$base_ip" | awk -F. '{print $4}')
        
        # Validate range number (must be greater than last octet and <= 255)
        if ((end_part > last_octet && end_part <= 255))
        then
            return 0
        fi
    fi
    return 1
}

function validate_ip_regex() 
{
    local ip=$1  # Accept parameter
    if [[ $ip =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] 
    then
        return 0
    else
        return 1
    fi
}

function validate_cidr() 
{
    local cidr=$1
    if [[ $cidr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]] 
    then
        local ip_part="${cidr%/*}"
        local mask_part="${cidr#*/}"
        
        # Validate IP part
        if validate_ip_regex "$ip_part" && ((mask_part >= 0 && mask_part <= 32)) 
        then
            return 0
        fi
    fi
    return 1
}

function InfoGather()
{
	sleep 4
	clear
    echo -e ${YELLOW} "Please Insert an ip range to scan!" ${NC}
    read Address
    
    # Test all three formats
    if validate_ip_regex "$Address" 
    then
        echo -e ${GR} "✓ Valid IP address" ${NC}
        echo '-----------------------------------------'
    elif validate_cidr "$Address" 
    then
        echo -e ${GR} "✓ Valid CIDR range" ${NC}
        echo '-----------------------------------------'
    elif validate_ip_range "$Address" 
    then
        echo -e ${GR} "✓ Valid IP range" ${NC}
        echo '-----------------------------------------'
    else
        echo -e ${RED} "✗ Invalid IP address or range format" ${NC}
        echo "-----------------------------------------------------"
        echo -e ${OR} "  - Please use formats like:" ${NC}
        echo -e ${OR} "  - Single IP: 192.168.1.1" ${NC}
        echo -e ${OR} "  - CIDR: 192.168.1.0/24" ${NC}
        echo -e ${OR} "  - Range: 192.168.1.10-50" ${NC}
        echo '-----------------------------------------'
        InfoGather
        return
    fi
    
    echo -e ${YELLOW}"Please Specify the Directory Name to save into" ${NC}
    read Dir
    mkdir -p "$Dir"
    echo '------------------------------------------------------------'
    echo -e ${BLUE} "Scanning $Address" ${NC}
    nmap "$Address" -sL | grep for | awk '{print $NF}' > "$Dir/iplist.txt"
    echo -e ${GR} "Scan completed! Results saved to $Dir/iplist.txt" ${NC}
    echo '--------------------------------------------------------------'
}
InfoGather

function full()
{
	sleep 4
	clear
	echo -e ${BLUE} " Starting Full Scan Of $Address" ${NC}
	echo "--------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap
	
for ips in $(cat $Dir/iplist.txt) #loop to run the nmap scans for all the ips in the list
	do 
	mkdir -p $Dir/Scan_nmap/nmap_serv
	echo -e ${OR} "Starting Scan For Services on $ips" ${NC}
	nmap $ips -sV --open -oA $Dir/Scan_nmap/nmap_serv/"$ips"_serv &>/dev/null
	rm -rf $Dir/Scan_nmap/nmap_serv/*.gnmap
	echo -e ${GR} "Complete! Procceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap/nmap_vuln
	echo -e ${RED} " Starting Vulnability Check! Saving Into: $Dir/Scan_nmap/nmap_vuln/"$ips"_vuln.txt " ${NC}
	nmap $ips --open --script=vuln -oX "$Dir/Scan_nmap/nmap_vuln/$ips"_vuln.xml | sed -n '/VULNERABLE:/,/|_/p' | tee -a $Dir/Scan_nmap/nmap_vuln/"$ips"_vuln.txt
	echo -e ${GR} " Done! Proceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap/nmap_auth
	echo -e ${RED} "Starting Authication Bypass Check! Saving into: $Dir/Scan_nmap/nmap_auth/"$ips"_auth.txt " ${NC}
	nmap $ips --open --script=auth -oX "$Dir/Scan_nmap/nmap_auth/$ips"_auth.xml | sed -n '/Host script results:/,/Nmap done:/p' | tee -a $Dir/Scan_nmap/nmap_auth/"$ips"_auth.txt
	echo -e ${GR} " Done! Proceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap/nmap_malware
	echo -e ${RED} " Starting Malware Check! Saving Into: $Dir/Scan_nmap/nmap_malware/"$ips"_malware.txt " ${NC}
	nmap $ips --open --script=malware -oX "$Dir/Scan_nmap/nmap_malware/$ips"_malware.xml | sed -n '/VULNERABLE:/,/|_/p' | tee -a $Dir/Scan_nmap/nmap_malware/"$ips"_malware.txt
	echo -e ${GR} " Done! Proceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	done
	
for xmls in $(ls $Dir/Scan_nmap/nmap_*/*.xml) #changing all the xml's into htmls for future reffrence
	do
	xsltproc $xmls -o "$xmls".html
	done
	
}

function base()
{
	sleep 4
	clear
	echo -e ${BLUE} " Starting Basic Scan Of $Address" ${NC}
	echo "--------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap
	
for ips in $(cat $Dir/iplist.txt)
	do 
	mkdir -p $Dir/Scan_nmap/nmap_vers
	echo -e ${OR} "Starting Scan For Versions on $ips" ${NC}
	nmap $ips -sV --open -oA $Dir/Scan_nmap/nmap_vers/"$ips"_vers &>/dev/null
	rm -rf $Dir/Scan_nmap/nmap_vers/*.gnmap
	echo -e ${GR} "Complete! Procceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap/nmap_serv
	echo -e ${OR} "Starting Scan For Services on $ips" ${NC}
	nmap $ips -sS --open -oA $Dir/Scan_nmap/nmap_serv/"$ips"_serv &>/dev/null
	rm -rf $Dir/Scan_nmap/nmap_serv/*.gnmap
	echo -e ${GR} "Complete! Procceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	mkdir -p $Dir/Scan_nmap/nmap_udp
	echo -e ${OR} "Starting Scan For Udp open ports on $ips" ${NC}
	nmap $ips -sU --top-ports 20 --open -oA $Dir/Scan_nmap/nmap_udp/"$ips"_udp &>/dev/null
	rm -rf $Dir/Scan_nmap/nmap_udp/*.gnmap
	echo -e ${GR} "Complete! Procceeding!" ${NC}
	echo "--------------------------------------------------------------------"
	done
	
	sleep 5
	
for xmls in $(ls $Dir/Scan_nmap/nmap_*/*.xml)
	do
	xsltproc $xmls -o "$xmls".html
	done
	
}

function weak() 
{

	
function services() 
{
	echo -e ${RED} "Please Select A service to test!"
	read Serv
	if [ "$Serv" == "SSH" ] || [ "$Serv" == "ssh" ]
	then
	cat $Dir/Scan_nmap/nmap_serv/*.nmap | grep -w ssh
	echo -e ${GR} "Service Found Procceeding" ${NC}
	echo "--------------------------------------------------------------------"
	elif [ "$Serv" == "FTP" ] || [ "$Serv" == "ftp" ]
	then
	cat $Dir/Scan_nmap/nmap_serv/*.nmap | grep -w ftp
	echo -e ${GR} "Service Found Procceeding" ${NC}
	echo "--------------------------------------------------------------------"
	elif [ "$Serv" == "telnet" ] || [ "$Serv" == "TELNET" ]
	then
	cat $Dir/Scan_nmap/nmap_serv/*.nmap | grep -w telnet
	echo -e ${GR} "Service Found Procceeding" ${NC}
	echo "--------------------------------------------------------------------"
	else 
	echo -e ${OR} " The $Serv not found please try another! (ssh,ftp,telnet)" ${NC}
	echo "--------------------------------------------------------------------"
	services
	fi 
}	
services

echo -e ${GR} "Using $Serv service for Tetsting" ${NC}
echo '-----------------------------------------'
echo -e ${YELLOW} "Starting Credentials Testing!" ${NC}
echo "-----------------------------------------------------------"
cd $Dir
echo -e ${YELLOW} "Would you like to create your own User list to test? [Y/N] " ${NC}
read weakuser

if [ "$weakuser" == 'Y' ] || [ "$weakuser" == 'y' ] || [ "$weakuser" == 'yes' ] || [ "$weakuser" == 'Yes' ] 
then
    echo -e ${BLUE} "Creating custom user list. Type each username and press Enter."
    echo -e ${BLUE} "When finished, type 'X' on a new line and press Enter." ${NC}
    
    # Create/clear the user list file
    > userlist.txt
    
    user_count=0
    while true 
    do
        read -p "Username $((user_count + 1)): " username #visual counting of options you enter
        if [ "$username" == "X" ] || [ "$username" == "x" ] 
        then
        break
        fi
        if [ -n "$username" ] 
        then
            echo "$username" >> userlist.txt
            user_count=$((user_count + 1))
        fi
    done
    
    echo -e ${GREEN} "Created custom user list with $user_count users in userlist.txt" ${NC}
    echo '-----------------------------------------------------------------------------'
    
else
    echo -e ${BLUE} "Downloading Prepared User List for Testing" ${NC}
    wget https://pastebin.com/raw/9WfTbaTs -O userlist.txt &>/dev/null
    
    if [ $? -eq 0 ] 
    then
        echo -e ${GREEN} "Download successful! Created File Named: userlist.txt in $(pwd)" ${NC}
        echo '-----------------------------------------------------------------------------'
    else
        echo -e ${RED} "Download failed! Creating default user list..." ${NC}
        # Create a default user list as fallback
        cat > userlist.txt << EOF
	admin
	root
	test
	guest
	user
	administrator
EOF
        echo -e ${YELLOW} "Created default user list with common usernames" ${NC}
    fi
    echo "--------------------------------------------------"
fi

echo -e ${GR} "Using $Serv service for Testing" ${NC}
echo '-----------------------------------------------------------'
echo -e ${YELLOW} "Would you like to create your own Pass list to test? [Y/N] " ${NC}
read weakpass

if [ "$weakpass" == 'Y' ] || [ "$weakpass" == 'y' ] 
then
    echo -e ${BLUE} "Creating custom Pass list. Type each Password and press Enter."
    echo -e ${BLUE} "When finished, type 'X' on a new line and press Enter." ${NC}
    # Create/clear the pass list file
    > passlist.txt
    
    pass_count=0
    while true 
    do
        read -p "Password $((pass_count + 1)): " password  #visual counting of options you enter
        if [ "$password" == "X" ] || [ "$password" == "x" ] 
        then
        break 
        fi
        if [ -n "$password" ] 
        then
            echo "$password" >> passlist.txt
            pass_count=$((pass_count + 1))
        fi
done
    
    echo -e ${GREEN} "Created custom Pass list with $pass_count users in passlist.txt" ${NC}
    echo '-----------------------------------------------------------------------------'
else
    echo -e ${BLUE} "Downloading Prepared Pass List for Testing" ${NC} #pre-made passlist saved into pastebin for use
    wget https://pastebin.com/raw/avYRL8ps -O passlist.txt &>/dev/null
    if [ $? -eq 0 ] 
    then
        echo -e ${GREEN} "Download successful! Created File Named: passlist.txt in $(pwd)" ${NC}
    else
        echo -e ${RED} "Download failed! Creating default pass list..." ${NC}
        # Create a default password list as fallback
        cat > passlist.txt << EOF
admin
root
test
guest
user
administrator
EOF
        echo -e ${YELLOW} "Created default passlist list with common passwords" ${NC}
    fi
    echo "--------------------------------------------------"
    
fi
	echo -e ${RED} "Starting Credentials Test! Hold Tight!" ${NC}
	hydra -L userlist.txt -P passlist.txt -M iplist.txt $Serv -t 4| tee -a WeakCr.txt
	echo -e ${GR} "Test Complete! Results Saved to $Dir/WeakCr.txt!" ${NC}
	
	cd ..
}

function sploit()
{
	sleep 4
	clear
	mkdir $Dir/searchsploit
	echo -e ${RED} "Starting to Gather service version!" ${NC}
	echo "------------------------------------------------------------------------------"
	echo -e ${OR} "Found the next services for sploit testing: " ${NC}
	cat $Dir/Scan_nmap/nmap_serv/*.nmap| grep 'PORT' -A100 | grep 'open' | awk '{print $4,$5,$6}' | grep '\S' | grep -v '(access denied)' | sed 's/[()/\\|&;]/_/g' | tee -a $Dir/sploits.txt #removing all the \ ! signs so it wont pop up errors)
	echo "------------------------------------------------------------------------------"
	
	echo -e ${YELLOW} " Starting Testing with Searchsploit! " ${NC}
	
	for sploits in $( cat $Dir/sploits.txt )
	do
	searchsploit -e $sploits > $Dir/searchsploit/"$sploits"_exp.txt
	done
	echo -e ${OR} " Removing Empty Files"
	find $Dir/searchsploit -type f -size 63c -delete #files with no data in it weights 63b so deleting them
	echo -e ${GR} " Complete! "
	echo "----------------------------------------------------------------------"
	echo -e ${GR} " Testing Complete! all information saved in Searsploit Folder in $Dir" ${NC}
	echo "----------------------------------------------------------------------"
}

function report()
{
	sleep 4
	clear
	find "$Dir" -name "*.nmap" -exec sh -c 'mv "$1" "${1%.nmap}.txt"' _ {} \; #renaming nmap output to txt to add in the count
    HTML=$(find $Dir -maxdepth 3 -type f -name "*.html")
    TXT=$(find $Dir -maxdepth 3 -type f -name "*.txt")
    FILE=$(find $Dir -maxdepth 3 -type d)
    
    echo -e ${RED} "Entering The Final Stage! Generating Report for the Scan!" ${NC}
    echo "-----------------------------------------------------------------------------"
    echo -e ${OR} " Generating Report For Created Directories " ${NC}
    echo -e ${GR} " Total Created Directories : '$(echo "$FILE" | wc -l)' " ${NC}
    echo "------------------------------------------------------------"
    echo -e ${OR} " Generating Report For Created Txt Reports " ${NC}
    echo -e ${GR} " Total Created Txt Files :  '$(echo "$TXT" | wc -l)'  " ${NC}
    echo "------------------------------------------------------------"
	echo -e ${OR} " Generating Report For Created Credentials Reports " ${NC}
	if [ -f "$Dir/WeakCr.txt" ] 
	then
    echo -e ${GR} "Credentials Test Results:" ${NC}
    cat "$Dir/WeakCr.txt" | sed -n '/attacking/,/valid passwords found/p'
    echo -e ${RED} " Please Check Into it! " ${NC}
	else
    echo -e ${RED} "No credentials report found at $Dir/WeakCr.txt" ${NC}
fi
    echo "------------------------------------------------------------"
    
    echo -e ${OR} " Checking For Html Files " ${NC}
    if [ -z "$HTML" ]
    then
        echo -e ${RED} " No Html Files Found! " ${NC}
        echo '------------------------------------------'
    else
        echo -e ${GR} " Found: $(echo "$HTML" | wc -l) html files. " ${NC}
        echo -e ${OR} " Would you like to View them? (yes/no) " ${NC}
        read View
        if [ "$View" = "yes" ] || [ "$View" = "Yes" ]
        then
        echo '------------------------------------------------------'
            # Open each HTML file in firefox
            for html_file in $HTML 
            do
                firefox "$html_file" 2>/dev/null &
            done
        else
            echo -e ${GR} " Total Created HTML Files :  '$(echo "$HTML" | wc -l)'  " ${NC}
            echo -e ${OR} " I'll leave them for you for later then... " ${NC}
            echo '-------------------------------------------------------------'
        fi
    fi
    
    echo -e ${OR} " Generating Report For Searchsploit " ${NC}
    if [ -d "$Dir/searchsploit" ] 
    then
        echo -e ${GR} " Total Files Created: $(ls -l "$Dir/searchsploit/" | wc -l) " ${NC}
    else
        echo -e ${RED} " No searchsploit directory found " ${NC}
    fi
    echo '------------------------------------------------------------------------'

    echo -e ${BLUE} "Would you Like To Check Report For Specific Ip? (yes/no) " ${NC}
    read SPIP
    if [ "$SPIP" = "yes" ] || [ "$SPIP" = "Yes" ] || [ "$SPIP" = "y" ]
    then
        echo -e ${GR} "Which Ip Would you Like to See? " ${NC}
        read IP
        echo -e ${OR} " Generating Report For $IP " ${NC}
        echo -e ${GR} " Total Txt Files For $IP : $(find $Dir -maxdepth 3 -type f -name "*$IP*.txt" | wc -l) " ${NC}
        echo '=================================================================================='
        echo -e ${GR} " Total html Files For $IP : $(find $Dir -maxdepth 3 -type f -name "*$IP*.html" | wc -l) "  ${NC} 
        echo -e ${OR} " Would you Like to View Them? (yes/no) " ${NC}
        read view2
		if [ "$view2" == "yes" ] || [ "$view2" == "Yes" ] || [ "$view2" == "y" ]
		then
		# Open all HTML files for this IP in all Scan_nmap subdirectories
		for html_file in "$Dir"/Scan_nmap/*/*"$IP"*.html 
		do
        if [ -f "$html_file" ] 
        then
            echo -e ${BLUE} "Opening: $html_file" ${NC}
            firefox "$html_file" 2>/dev/null &
            sleep 1
        fi
    done
    fi
        echo '=================================================================================='
    else 
        echo -e ${BLUE} " Proceeding To final Stage! " ${NC}
        echo '-------------------------------------------------'
    fi
    

}

function zipme()
{
	sleep 4
	clear
	echo -e ${RED} "Would you like to zip it all? (Yes/No)" ${NC}
	read zip
	if [ $zip == "yes" ] || [ $zip == "Yes" ]
	then
	echo -e ${OR} " Starting Ziping $Dir " ${NC}
	zip -r "$Dir.zip" "$Dir" &>/dev/null 
	echo -e ${GR} "File $Dir.zip Created!" ${NC}
	echo '------------------------------------'
	echo -e ${RED} " Removing Unnecesary leftovers! "
	rm -rf $Dir
	echo -e ${GR} " Done " ${NC}
	else
	echo -e ${BLUE} " Leaving all as it is! " ${NC}
	echo '------------------------------------'
	fi
	
}


function main_menu ()
{
	sleep 4
	clear
while true 
	do
	echo -e ${BLUE}"=== Scan Menu === "${NC}
    echo -e ${GR}"1) Basic Scan (Services,versions weak_creds)" ${NC} 
    echo -e ${GR}"2) Full Scan (Services,versions,vulnabilaties,weak_creds)" ${NC} 
    echo -e ${RED}"3) Exit "${NC}
    echo -e ${BLUE}"==========================="${NC}
    read -p "Select an option: " OPTION
    
case $OPTION in
            1)  echo -e ${BLUE} "Entering Basic Scan!" ${NC}
                base
                weak
                report
                zipme
                ;;
            2) echo -e ${YELLOW} "Entering Full Scan" ${NC}
                full
                weak
                sploit
                report
                zipme
                ;;
            3) echo -e ${RED} "What a scan it was... " ${NC}
				end=$(date +%s)
				duration=$(($end - $start))
				echo -e ${GR} "Total Work duration: $duration seconds" ${NC}
				echo -e ${GR} "All Clean And Tidy, Exiting" ${NC} 
                exit 0
                ;;
            *) echo -e ${RED} "Invalid option, please try again" ${NC}
                ;;
        esac
    done
}
main_menu
