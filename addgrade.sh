#/bin/bash

#
# Adds grades of students to database  
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"
GRADE_REGEX="^[0-9][0-9][0-9]*$"

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

#Initial prompt   
echo "WHAT IS THE TITLE OF THE GRADE? "
read title 
echo "YOU ARE GOING TO ADD THE GRADE OF $title ..."
echo "HOW DO YOU LIKE TO SEARCH FOR THE USER? (LNAME/FNAME/SID)"
read option
option=$( echo $option | awk '{print toupper($0)}' )
if [[ $option != "LNAME" && $option != "FNAME" && $option != "SID" ]] ; then
	echo "INVALID KEY. EXITING ADDGRADE UTILITY..."
	exit 1
fi
echo "YOU ARE GOING TO USE $option. PLEASE MAKE SURE THE NAME IS MATCHING."
echo "PROCESSING..."

class_grade=$( echo "$class-G" )

#Tests if related grade file already exists
if [ ! -f $class_grade ] ; then
	touch $class_grade
	#first execution
	echo "SID:LNAME:FNAME:$title" >> $class_grade

	IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(cat $class))
	for i in ${RECORDS[@]}; do
		lname=$( echo $i | cut -d":" -f1 )
		fname=$( echo $i | cut -d":" -f2 )
		sid=$( echo $i | cut -d":" -f3 )
		echo "$sid:$lname:$fname:" >> $class_grade
	done
else 
	echo "" > temp
	IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(cat $class_grade))
	echo "${RECORDS[0]}:$title" >> temp 
	array_size=${#RECORDS[@]}
	i=1
	while [ $i -lt $array_size ]
	do
		echo "${RECORDS[$i]}:" >> temp 
		i=$(( $i + 1 ))
	done;
	mv temp $class_grade
fi

#Process students grades   
while [ true ] 
do
	echo "$option: (Type ; character to exit)"
	read entry
	
	if [[ $entry == ";" ]] ; then
		echo "FINISHING.."
		break
	fi

	#Search for student
	if [ $option == "SID" ] ; then
		awk -v e="$entry" -F: '$1 == e { OFS=";"; print $0, NR }' $class_grade >> output 
	elif [ $option  == "LNAME" ] ; then
		awk -v e="$entry" -F: '$2 == e { OFS=";"; print $0, NR }' $class_grade >> output 
	elif [ $option  == "FNAME" ] ; then
		awk -v e="$entry" -F: '$3 == e { OFS=";"; print $0, NR }' $class_grade >> output 
	else
		echo "ERROR PROCESSING ENTRY... "
		continue
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

		student=$( echo $i | cut -d";" -f1 )
		line_number=$( echo $i | cut -d";" -f2 )

		sid=$( echo $student | cut -d":" -f1 )
		lname=$( echo $student | cut -d":" -f2 )
		fname=$( echo $student | cut -d":" -f3 )

		echo
		echo "IT'S $lname, $fname . CORRECT? (Y/N) "
		read answer
		if [[ $answer == "Y" || $answer == "y" ]] ; then 
			echo "THE GRADE OF $lname: "
			read grade 
			
			if [[ $grade =~ "$GRADE_REGEX" ]] ; then 
				echo "INVALID GRADE. GRADE WAS NOT INSERTED. "
				continue
			fi
			
			#modify data here
			awk -v l="$line_number" -v g="$grade" -F: '{ if (NR == l) { OFS=":"; print $0, g } else { print $0 } }' $class_grade >> output2 
			#Something wrong going on here
			mv output2 $class_grade
		elif [[ $answer == "N" || $answer == "n" ]] ; then 
				continue
		else
			echo "INVALID OPTION. RECORD NOT REMOVED."
		fi

	done;
	
	rm output

done

echo "EXITING ADDGRADE UTILITY..."

