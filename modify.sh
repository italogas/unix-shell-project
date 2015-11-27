#/bin/bash

#
# Modifies students information 
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"
ENTRY_REGEX="^[a-zA-Z][a-zA-Z]*$"

CLASS_FOUND_FLAG=0

#Check for right number of arguments
if [ "$#" -lt 3 ] ; then
	echo "Usage: modify [-email -lname -fname -sid -phone ] [ entry ] [ class ]"
	echo "EXITING MODIFY UTILITY..."
	exit 1
fi

option=$1
entry=$2
class=$3

case "$option"
in        
	"-lname") MODIFY_FIELD=1; OPTION="LAST NAME";;         
	"-fname") MODIFY_FIELD=2; OPTION="FIRST NAME";;         
	"-sid") MODIFY_FIELD=3; OPTION="SID";;         
	"-email") MODIFY_FIELD=4; OPTION="EMAIL ADDRESS";;         
	"-phone") MODIFY_FIELD=5; OPTION="PHONE NUMBER";;         
        *) echo "Bad argument; please specify a valid one. "; echo "EXITING MODIFY UTILITY..."; exit 1;;
esac

#Checks if class name is a valid one
if [[ ! "$entry" =~ $ENTRY_REGEX ]] ; then
	echo "ENTRY NOT VALID. EXITING MODIFY UTILITY..."
	exit 1
fi

#Checks if entry name is a valid one
if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING MODIFY UTILITY..."
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
	echo "CLASS NOT FOUND. EXITING MODIFY UTILITY..."
	exit 1
fi

#Process class-list   

echo "PROCESSING..."

awk -v e="$entry" -F: '$1 == e { print $0, NR }' $class > output 

if [ ! -s output ] ; then
	echo "ENTRY NOT FOUND. EXITING MODIFY UTILITY..."
	rm output
	exit 1
fi

record=$( cat output | cut -d" " -f1 )
line_number=$( cat output | cut -d" " -f2 )
field=$( echo $record | cut -d":" -f"$MODIFY_FIELD" ) 
rm output

echo
echo $record
echo
echo "CURRENT $OPTION IS: $field"
echo
echo "ENTER NEW $OPTION: "
read new_entry 
echo

#modify record here
awk -v ne="$new_entry" -v line="$line_number" -v mf="$MODIFY_FIELD" -F: 'NR == line { gsub( $mf, ne, $mf ); OFS=":"; print $0 }' $class >> $class 

#remove old record
awk -v line="$line_number" -F: 'NR != line { OFS=":"; print $0 }' $class >> out 

mv out $class

