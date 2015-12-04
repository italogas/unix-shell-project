#/bin/bash

#
# Prints grades of students 
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"

CLASS_FOUND_FLAG=0

#Check for right number of arguments
if [ "$#" != 2 ] ; then
	echo "Usage: printreport [ class-name ] [ option ]"
	echo "EXITING PRINTREPORT UTILITY..."
	exit 1
fi

class=$1

#Checks if class name is a valid identifier
if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING PRINTREPORT UTILITY..."
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
	echo "CLASS NOT FOUND. EXITING PRINTREPORT UTILITY..."
	exit 1
fi

class_grade_policy=$( echo "$class-G-P" )
if [ ! -f $class_grade_policy ] ; then
	echo "CLASS POLICY FILE NOT FOUND. EXITING PRINTREPORT UTILITY..." 
	exit 1
fi

c=$( echo $class | cut -d"_" -f1 ) 
s=$( echo $class | cut -d"_" -f2 ) 
echo "CLASS: $c		SECTION: $s " > final_report_$class
echo >> final_report_$class
echo "SID		LNAME			FNAME			GRADE" >> final_report_$class
echo "---		---			---			---" >> final_report_$class

awk -F: 'NR != 1 { OFS="		"; print $1, $2, $3, $15 }' $class_grade_policy >> final_report_$class 

echo >> final_report_$class
echo >> final_report_$class
echo >> final_report_$class

m=$( date | cut -d" " -f2 ) 
d=$( date | cut -d" " -f4 )
y=$( date | cut -d" " -f7 )
date=$( echo "$m.$d.$y" )
echo "PROFESSOR SIGNATURE: _____________________________________		DATE: $date " >> final_report_$class

