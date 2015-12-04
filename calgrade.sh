#/bin/bash

#
# Sums up total of students grades to database  
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9][-G]$"

#Check for right number of arguments
if [ "$#" != 1 ] ; then
	echo "Usage: calgrade [ class-grade-name ]"
	echo "EXITING CALGRADE UTILITY..."
	exit 1
fi

class_grades=$1

#Checks if class grade exists 
if [ ! -f "$class_grades" ] ; then
	echo "CLASS GRADES FILE DO NOT EXISTS. EXITING CALGRADE UTILITY..."
	exit 1
fi

HW_REGEX="^hw[0-9]*$"
EXAM_REGEX=""
PROJ_REGEX=""
QUIZ_REGEX=""

assignments=( "h" "e" "q" "p" )
for i in $assignments; do

	echo "ADDING $i GRADES FOR ALL STUDENTS   ... "

	awk -F: '{ for(i=1; i<=NF; i++) { if ( $NF ~ /^'$i' ) print NF } }' $class_grade > fields
	
	awk -F: '$NF ~ /^'$i'/' $class_grade > fields

	IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(echo $class_grades))
	array_size=${#RECORDS[@]}
	echo "${RECORDS[0]}:$i" >> output
	j=1

	awk -v $i -F: '{ { BEGIN counter=0; } if (NF = 0) { print $0, g } } }' $class_grade >> output 

	while [ $j < $array_size ] do

		#add grades here
		awk -v $i -F: '{ { BEGIN counter=0; } if (NF = 1) { print $0, g } } }' $class_grade >> output 

	j=$( $j + 1  )
	done;

	mv output $class_grade
	echo " DONE. "
done;

rm output
echo "EXITING CALRADE UTILITY..."

