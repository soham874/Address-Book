#!/bin/bash

####	CURRENT ABILITIES AND COMMENTS     ####
#### | #-Final code | ##-Need to be done | #?-Rectify bugs
# select/create new working file from directory
# add new data	
# view data for particular person, based on full name
# view data sorted by last name and zip, ascending and descending
# delete all user data
# delete a particular user data, based on full name
# edit a particular user data, based on full name

####	USED FUNCTIONS    ####
# InitMenu >> Main menu driver
# DeleteDataMenu >> Menu driver for editing old data
# ReadOldDataMenu >> Menu driver for reading old data

# Initialize >> gather vital data from address book
# Sortedinfo >> Output sorted data, no return
# EnterNewData >> Used for data entry
# Patterncheck >> verifies new entries, no return
# NameCheck >> searches for name in book
# DeleteData >> Deletes paticular entries
# EditData >> Edits particular entries

shopt -s extglob
declare -a fullNameArray

function Initialize(){
	entryCount=$(cat $inputFile | awk 'END{print NR}')
	for ((i=1;i<=$entryCount;i++))
	do
		var=`head -$((i)) $inputFile | tail -1`
		fullNameArray[$((i-1))]=`echo $var | awk -F"|" '{print $1 $2}'`
	done
}

function InitMenu(){
	printf "\n"
	echo "#### Main Address Book Menu ###"
	echo "Enter your choice : "
	echo "1> Enter new data "
	echo "2> Read old data"
	echo "3> Edit old data"
	echo "4> Exit the address book"
	read init
	case $init in
		1)
			EnterNewData;;
		2)
			ReadOldDataMenu;;
		3)
			DeleteDataMenu;;	
		4)
			printf "\n"
			echo "Number of records = $entryCount"
			echo "Updating backup for address book...done"
			cp $inputFile backup$inputFile
			printf "\n"
			echo "Thank you for using address book."
			exit 0
			;;
		*)
			echo "Wrong choice. Please try again."
			InitMenu;;
	esac
}

function EnterNewData(){
	printf "\n"
	echo "#### New data Entry ###"
	read -p "Enter First name : " firstname
	read -p "Enter Last name : " lastname
	read -p "Enter Address : " address
	read -p "Enter city : " city
	read -p "Enter state : " state
	#read -p "Enter ZIP : " ZIP
	#read -p "Enter phone number : " phone
	ZIP=$(shuf -i 100000-999999 -n 1) 
	phone=$(shuf -i 6999999999-9999999999 -n 1)
	Patterncheck "$firstname" "$lastname" "$address" "$city" "$state" $ZIP $phone
	InitMenu
}

function Patterncheck(){
	flag=0
	patNameCityState='^[[:upper:]]{1}[[:lower:]]{2,}.*$'
	patAddress='^.{10,}$'
	patZIP='^[[:digit:]]{6}$'
	patPhone='^[[:digit:]]{10}$'
	if [[ $1 =~ $patNameCityState && $2 =~ $patNameCityState && $3 =~ $patAddress && $4 =~ $patNameCityState && $5 =~ $patNameCityState && $6 =~ $patZIP && $7 =~ $patPhone ]]
	then
		printf "%-15s|%-15s|%-50s|%-20s|%-20s|%d\t|%d\n" "$1" "$2" "$3" "$4" "$5" $6 $7 >> $inputFile
		((flag++))
		echo "#### New data received and updated ###"
		Initialize
	else
		echo "Error in data input. Note that the  first name, last name, city and state must start with capital and be at least 3 alphabets long."
		echo "The address must be at least 10 charecters long, PIN should be 6 digit and phone number must be 10 digits. Please try again."
	fi
	if [[ $8 -eq 1 && $flag -ne 0 ]]
	then
		DeleteData $ipos
		EditData $9
	fi
}		

function ReadOldDataMenu(){
	printf "\n"
	echo "### Check previous data ###"
	echo "Enter your choice : "
	echo "1> View data for a particular person"
	echo "2> View all data present in address book, sorted by last name or ZIP"
	echo "3> Return to previous menu"
	read readchoice
	case $readchoice in
		1)
			printf "\n"
			read -p "Enter full Name of the person : " searchName
			NameCheck "$searchName "
			;;
		2)
			printf "\n"
			Sortedinfo 
			;;	
		3)
			InitMenu;;
		*)
			echo "Wrong choice. Please try again."
			ReadOldDataMenu;;
	esac
}

function Sortedinfo(){
	printf "\n"
	echo "### Printing all data in sorted order ###"
	read -p "Enter 0 to sort ascending and 1 to sort descending : " choice1
	read -p "Enter 0 to sort by last name and 1 to sort by ZIP : " choice2
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~Address book Data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if [[ $choice1 == 0 && $choice2 == 1 ]] 
	then
		sort -k6 -n -t"|" $inputFile
	elif [[ $choice1 == 1 && $choice2 == 1 ]] 
	then
		sort -k6 -nr -t"|" $inputFile
	elif [[ $choice1 == 1 && $choice2 == 0 ]] 
	then
		sort -k2 -r -t"|" $inputFile
	else
		sort -k2 -t"|" $inputFile
	fi
	ReadOldDataMenu
}

function DeleteDataMenu(){
	printf "\n"
	echo "### Edit existing data ###"
	echo "1> Delete all data"
	echo "2> Delete particular data of of an existing person"
	echo "3> Edit particular data of an existing person"
	echo "4> Return to main menu"
	read choice
	case $choice in
		1) 
			rm $inputFile
			touch $inputFile
			Initialize
			echo "The address book has been cleared!!"
			((deletions++))
			DeleteDataMenu;;
		2)
			read -p "Enter full Name of the person : " searchName
			NameCheck "$searchName " 1
			;;
		3)
			read -p "Enter full Name of the person : " searchName
			NameCheck "$searchName " 2
			;;
		4)
			InitMenu;;
		*)
			echo "Wrong choice. Please Enter again."
			DeleteDataMenu;;
	esac			
}

function NameCheck(){
	flag=0
	ipos=0
	for i in ${!fullNameArray[@]}
	do
		if [[ "$1" == ${fullNameArray[$i]} ]]
		then
			flag=1
			ipos=$i
			echo "Following data has been found in record..."
			var=`head -$((i+1)) $inputFile | tail -1`
			echo $var | awk -F"|" '{print "\n"$1 $2 "\n" $3 "\n" $4 ", " $5 "- " $6 "\nPhone : "$7 "\n"}'
		fi
	done
	if [[ $flag -eq 0 ]]
	then
		echo "Sorry. Record not found"
	fi

	if [[ $2 -eq 1 && $flag -eq 1 ]]
	then
		read -p "Press 1 to confirm deletion of this person's data and 0 to abort : " choice
		case $choice in 
			0) 
				echo "Deletion aborted"
				;;
			1)
				DeleteData $ipos
				;;
			*)
				echo "Wrong choice"
				;;
		esac
	elif [[ $2 -eq 2 && $flag -eq 1 ]]
	then
		read -p "Press 1 to confirm editting of this person's data and 0 to abort : " choice
		case $choice in 
			0) 
				echo "Editting old data aborted"
				;;
			1)
				EditData $ipos
				;;
			*)
				echo "Wrong choice"
				;;
		esac
	fi
	ReadOldDataMenu
}

function DeleteData(){
	removePosition=$1
	if [[ $removePosition -ne 0 ]]
	then
		head -$(echo $removePosition) $inputFile >> temp
	fi
	if [[ $removePosition -ne $(($entryCount-1)) ]]
	then
		tail -$(($entryCount-$removePosition-1)) $inputFile >> temp
	fi
	rm -r $inputFile
	mv temp $inputFile
	Initialize
}

function EditData(){
	var=`head -$(($1+1)) $inputFile | tail -1`
	firstname=`echo $var | awk -F"|" '{print $1}'`
	lastname=`echo $var | awk -F"|" '{print $2}'`
	address=`echo $var | awk -F"|" '{print $3}'`
	city=`echo $var | awk -F"|" '{print $4}'`
	state=`echo $var | awk -F"|" '{print $5}'`
	ZIP=`echo $var | awk -F"|" '{print $6}'`
	phone=`echo $var | awk -F"|" '{print $7}'`
	echo "Name is not changable. Other than that select which data you want to change."
	echo "<1> Address <2> City <3> State <4> ZIP <5> Phone"
	echo "Enter anything else to exit."
	read choice
	case $choice in
		1)
			read -p "Enter new Address : " address;;
		2)
			read -p "Enter new City : " city;;
		3)
			read -p "Enter new State : " state;;
		4) 
			read -p "Enter new ZIP : " ZIP;;
		5) 
			read -p "Enter new Phone number : " phone;;
		*)
			DeleteDataMenu;;
	esac
	Patterncheck "$firstname" "$lastname" "$address" "$city" "$state" $ZIP $phone 1 $1
}

printf "\n"
echo "Welcome to address book !!"
printf "\n"

echo "Address books located in current directory are :"
ls +(address)*.tsv
read -p "Enter name of file you want to work with, or enter a new file name : " inputFile
if [[ -f $inputFile ]]
then
	Initialize
	echo "Address book data file loaded."
else
	echo "New address book data file created."
	touch $inputFile
fi
InitMenu