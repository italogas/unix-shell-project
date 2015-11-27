#/bin/bash

#
# Removes a student from a list 
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"
ENTRY_REGEX="^[a-zA-Z][a-zA-Z]*$"
ENTRY_REGEX_2="^[0-9]*$"

CLASS_FOUND_FLAG=0

# Special function used to sort student list
sortStudentList() {
        sort -t":" -k1,1 $class > temp
        mv temp $class
}


#Check for right number of arguments
if [ "$#" != 2 ] ; then
	echo "Usage: remove [ lname | fname | sid  ] [ class-name ]"
	echo "EXITING REMOVE UTILITY..."
	exit 1
fi

entry=$1
class=$2

#Checks if entry name is a valid identifier
if [[ ! "$entry" =~ $ENTRY_REGEX ]] && [[ ! "$entry" =~ $ENTRY_REGEX_2 ]] ; then
	echo "ENTRY NOT VALID. EXITING REMOVE UTILITY..."
	exit 1
fi

#Checks if class name is a valid identifier
if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING REMOVE UTILITY..."
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
	echo "CLASS NOT FOUND. EXITING REMOVE UTILITY..."
	exit 1
fi

#Process class-list   

echo "PROCESSING..."

awk -v e="$entry" -F: '$1 == e  || $2 == e || $3 == e { OFS=";"; print $0, NR }' $class >> output 

if [ ! -s output ] ; then
	echo "ENTRY NOT FOUND. EXITING REMOVE UTILITY..."
	rm output
	exit 1
fi

newLines="$( wc -l output | cut -d" " -f1 )" 
if [ $newLines -gt 1 ] ; then
	echo "MORE THAN 1 ENTRY WAS FOUND. "
fi

IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(cat output))
for i in ${RECORDS[@]}; do

	record=$( echo $i | cut -d";" -f1 )
	line_number=$( echo $i | cut -d";" -f2 )

	echo
	echo "RECORD FOUND  IS: "
	echo $record
	echo
	echo "REMOVE IT? (Y/N)"
	read answer

	if [[ $answer == "Y" || $answer == "y" ]] ; then 
		#remove record
		awk -v line="$line_number" -F: 'NR != line { OFS=":"; print $0 }' $class >> out 
		mv out $class
		echo "RECORD REMOVED. "
	elif [[ $answer == "N" || $answer == "n" ]] ; then 
		echo "RECORD NOT REMOVED."
	else
		echo "INVALID OPTION. RECORD NOT REMOVED."
	fi
done;

rm output
sortStudentList
echo "EXITING REMOVE UTILITY..."

