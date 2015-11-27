#/bin/bash

#
# Adds grades of students to database  
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"

CLASS_FOUND_FLAG=0

#Check for right number of arguments
if [ "$#" != 1 ] ; then
	echo "Usage: addgrade [ class-name ]"
	echo "EXITING ADDGRADE UTILITY..."
	exit 1
fi

class=$1

#Checks if class name is a valid identifier
if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING ADDGRADE UTILITY..."
	exit 1
fi

#Checks if class exists 
IFS=$'\r\n' GLOBIGNORE='*' :; CLASSES=($(cat class-list))
for i in ${CLASSES[@]}; do
	if [ $i == $class ] ; then
		CLASS_FOUND_FLAG=1
		break;
	fi
done

if [ $CLASS_FOUND_FLAG == 0 ] ; then
	echo "CLASS NOT FOUND. EXITING ADDGRADE UTILITY..."
	exit 1
fi

#Process students grades   

class_grade=$( echo "$class-G" )
touch $class_grade

echo "WHAT IS THE TITLE OF THE GRADE? "
read title 
echo "YOU ARE GOING TO ADD THE GRADE OF $title ..."
echo "HOW DO YOU LIKE TO SEARCH FOR THE USER? (LNAME/FNAME/SID)"
read option
if [ $option != "LNAME" && $option != "FNAME" && $option != "SID" ] ; then
	echo "INVALID KEY. EXITING ADDGRADE UTILITY..."
	exit 1
fi
echo "YOU ARE GOING TO USE $option. PLEASE MAKE SURE THE NAME IS MATCHING."
echo "PROCESSING..."

while [ true ] 
do
	echo "$ENTRY: (Ctrl+C to exit)"
	read entry
	
	#Search for student
	if [ $entry == $option ] ; then
		awk -v e="$entry" -F: '$1 == e { print $0 }' $class >> output 
	elif [ $entry == $option ] ; then
		awk -v e="$entry" -F: '$2 == e { print $0 }' $class >> output 
	else
		awk -v e="$entry" -F: '$3 == e { print $0 }' $class >> output 
	fi


	if [ ! -s output ] ; then
		echo "ENTRY NOT FOUND. "
		continue
	fi

	newLines="$( wc -l output | cut -d" " -f1 )" 
	if [ $newLines -gt 1 ] ; then
		echo "MORE THAN 1 ENTRY WAS FOUND. "
	fi

	IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(cat output))
	for i in ${RECORDS[@]}; do

		lname=$( echo $i | cut -d":" -f1 )
		fname=$( echo $i | cut -d":" -f2 )
		sid=$( echo $i | cut -d":" -f3 )

		echo
		echo "IT'S $lname, $fname . CORRECT? (Y/N) "
		read answer
		if [[ $answer == "Y" || $answer == "y" ]] ; then 
			echo "THE GRADE OF $option: "
			read grade 
			echo $sid:$lname:$fname:$grade >> $grades
		elif [[ $answer == "N" || $answer == "n" ]] ; then 

		else
			echo "INVALID OPTION. RECORD NOT REMOVED."
		fi

	done;

	echo "" > output
done

rm output
echo "EXITING ADDGRADE UTILITY..."

