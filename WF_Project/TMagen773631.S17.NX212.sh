#!/bin/bash





function wfproject ()
{
	start=$(date +%s)
	
type_effect() # Typing Effect Function
{
    local text="$1"
    local delay="${2:-0.05}"
    for ((i=0; i<${#text}; i++))
    do
        echo -en "${text:$i:1}" 
        sleep "$delay"
    done
    echo
}

type_effect 'Welcome To Forensic Project!' 0.03
type_effect 'Enjoy The Script!' 0.03

		
function rootcheck()
{
USER=$(id -u)
	if [ "$USER" == "0" ]
	then
	type_effect 'Youre Root, Do continue' 0.02
	else
	type_effect 'Youre not Root, Change to Root and restart' 0.02
	sudo su root
	fi
	

}
rootcheck
	
	
	type_effect 'Starting To Check For Tools' 0.02
	type_effect '----------------------------------' 0.02

for TOOL in foremost bulk_extractor binwalk dd strings; 
	do
    type_effect "Checking For $TOOL..." 0.02
    if [ -z "$TOOL" ] &>/dev/null 
    then
        type_effect "[X] $TOOL is not installed. Installing..." 0.02
        sudo apt-get install -y "$TOOL" &>/dev/null
    else
        type_effect "[V] $TOOL is already installed" 0.01
    fi
    type_effect "----------------------------------" 0.01
done

	type_effect 'Installing Volatility3' 0.05
	sudo apt install -y python3 python3-pip git &>/dev/null
	git clone https://github.com/volatilityfoundation/volatility3.git &>/dev/null
	pip3 install -r requirements.txt &>/dev/null
	type_effect "Done!" 0.02
	type_effect "=======================================" 0.02
	
function filecheck()
{
	type_effect 'Please Insert The File' 0.01
	read FILE
	if [ -f $FILE ]
	then
	type_effect "The file is good lets procceed to work!"
	else 
	type_effect "The file is missing"
	type_effect "Try Again"
	filecheck
	type_effect "File name is: $FILE" 0.01
	fi

}
filecheck

function carving ()
{
	mkdir $FILE-Carved #Creating the Main Folder
	type_effect "[!] Starting Carving using Bulk Extractor,Foremost,Binwalk & Strings" 0.05
	type_effect "[*] Running Bulk Extractor!" 0.02
	bulk_extractor $FILE -o $FILE-Carved/bulkextractor &>/dev/null
	chmod 777 -R $FILE-Carved/bulkextractor
	type_effect "[!]Done" 0.02
	type_effect "=======================================" 0.02
	type_effect "[*] Running Foremost!" 0.02
	foremost -i $FILE -t all -o $FILE-Carved/foremost &>/dev/null
	chmod 777 -R $FILE-Carved/foremost
	type_effect "[!]Done" 0.02
	type_effect "=======================================" 0.02
	type_effect "[*] Running Binwalk!" 0.02
	binwalk -e --run-as=root $FILE -C $FILE-Carved/binwalk &>/dev/null
	chmod 777 -R $FILE-Carved/binwalk
	type_effect "[!]Done" 0.02
	type_effect "=======================================" 0.02
	type_effect "[*] Running Strings!" 0.02
	mkdir $FILE-Carved/Strings
	strings $FILE | grep -E -o '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b' > $FILE-Carved/Strings/$FILE-ipsdat.txt
	strings $FILE | grep -i "username\|user\|login" > $FILE-Carved/Strings/$FILE-usersdat.txt
	strings $FILE | grep -i "password\|pass\|hash\|md5\|sha1\|ntlm" > $FILE-Carved/Strings/$FILE-passdat.txt
	strings $FILE | grep -i "\.exe\|\.dll\|\.so\|\.bin" > $FILE-Carved/Strings/$FILE-exedat.txt
	strings $FILE | grep -i "ransom\|backdoor\|rat\|keylogger\|inject" > $FILE-Carved/Strings/$FILE-maldat.txt
	strings $FILE | grep -i -E -o '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' > $FILE-Carved/Strings/$FILE-maildat.txt
	type_effect "[!]Done" 0.02
	type_effect "=======================================" 0.02
	type_effect "[!]Carve Complete" 0.05
	type_effect "=======================================" 0.02
}
carving

function pcap_check ()
{
	type_effect "[!] Checking For Network file Pressence"
	CHECK=$(find "$FILE-Carved" -type f -name "*.pcap" | head -n 1)
	Weight=$(stat -c "%s" "$CHECK" 2>/dev/null) #Deepseek helped here
	if [ -z "$CHECK" ]
	then
	type_effect "No File Located"
	else
	type_effect "Found the file name $CHECK" | tee -a $FILE-Carved/pcapname.txt
	type_effect "The Folder Weights: $Weight bytes" | tee -a $FILE-Carved/pcapname.txt
	fi
}
pcap_check

	type_effect "[*]Making Apropriate Dir For Vol Data[*]" 0.02
	type_effect "[V]Directory Created" 0.02
	
sudo mkdir $FILE-Carved/Vol3data #putting this here so it wont be creaeted multiple times while returning to menu
	
function casevol ()
{
	type_effect "[!]Welcome To Vol3 Menu[!]" 0.02
	type_effect "Please Choose what would you like to know" 0.02
	type_effect "The Output will be saved in the txt format in the created Directory" 0.02
	echo "1. Windows info"
	echo "2. Running Proccesses"
	echo "3. Terminated Proccesses"
	echo "4. Dll's"
	echo "5. Netscan"
	echo "6. File Scan"
	echo "7. Hivelist"
	echo "8. Exit"
	
	read NUM
	
	case $NUM in
	
	1) type_effect "========================================" 0.02
	type_effect "Extracting Windows Info" 0.02
	python3 volatility3/vol.py -f "$FILE" windows.info | tee -a $FILE-Carved/Vol3data/wininfo.txt
	type_effect "========================================" 0.02
	casevol
	;;
	2) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.pslist 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600"  #assisted by Deepseek found how to extract the error in case it doesnt supporteed
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.pslist | tee -a $FILE-Carved/Vol3data/pslist.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	3) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.psscan 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600" 
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.psscan | tee -a $FILE-Carved/Vol3data/psscan.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	4) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.dlllist 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600" 
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.dlllist | tee -a $FILE-Carved/Vol3data/dlllist.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	5) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.netscan 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600" 
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.netscan | tee -a $FILE-Carved/Vol3data/netscan.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	6) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.filescan 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600" 
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.filescan | tee -a $FILE-Carved/Vol3data/filescan.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	7) type_effect "========================================" 0.02
	if 
	python3 volatility3/vol.py -f "$FILE" windows.registry.hivelist 2>&1 | grep -q "NotImplementedError: This version of Windows is not supported: 5\.1 15\.2600" 
	then
    type_effect "Not Supported"
	else
	python3 volatility3/vol.py -f "$FILE" windows.registry.hivelist | tee -a $FILE-Carved/Vol3data/hivelist.txt
	fi
	type_effect "========================================" 0.02
	casevol
	;;
	8) type_effect "========================================" 0.02
	type_effect "Exitting....."
	type_effect "========================================" 0.02
	;;
	*) type_effect "========================================" 0.02
	type_effect "Wrong Option, Try Again"
	type_effect "========================================" 0.02
	casevol
	;;
	esac
	
}	
casevol
	
	end=$(date +%s)
	duration=$(($end - $start))
	type_effect "Creating Report of Gathered Data"
	Extracted=$(find $FILE-Carved -type f -name '*' | wc -l)
	Jpgs=$(find $FILE-Carved -type f -name '*.jpg' | wc -l)
	Txt=$(find $FILE-Carved -type f -name '*.txt' | wc -l)
	Dll=$(find $FILE-Carved -type f -name '*.dll' | wc -l)
	Pcap=$(find $FILE-Carved -type f -name '*.pcap' | wc -l)
	type_effect "Number of Files Extracted $Extracted" | tee -a $FILE-Carved/Report.txt
	type_effect "Number Of Jpgs Extracted : $Jpgs" | tee -a $FILE-Carved/Report.txt
	type_effect "Number Of Txts Extracted : $Txt" | tee -a $FILE-Carved/Report.txt
	type_effect "Number Of Dlls Extracted : $Dll" | tee -a $FILE-Carved/Report.txt
	type_effect "Number Of Pcap Files Extacted : $Pcap" | tee -a $FILE-Carved/Report.txt
	type_effect "Duration of the Script in Seconds $duration" | tee -a $FILE-Carved/Report.txt
	type_effect "Creating Zip File of Data"
	Dir=$(pwd)
	zip -r $FILE-Carved.zip $Dir/$FILE-Carved &>/dev/null
	type_effect "Removing Extra Data and Volatility" 0.02
	rm -rf volatility3
	rm -rf $FILE-Carved
	type_effect "Done!" 0.02
	type_effect "Thank you For Using Us untill next time!" 0.01
}
wfproject
