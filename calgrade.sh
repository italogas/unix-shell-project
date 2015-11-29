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

assignments=( "HW" "EXAM" "QUIZ" "PROJ" )
for i in $assignments; do

	echo "ADDING $i GRADES FOR ALL STUDENTS   ... "

	IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(echo $class_grades))
	array_size=${#RECORDS[@]}
	echo "${RECORDS[0]}:$i" >> output
	j=1
	while [ $j < $array_size ] do

		#add grades here
		awk -v  -F: '{ { BEGIN counter=0; } if ($NF =~ ) { print $0, g } } }' $class_grade >> output 

	j=$( $j + 1  )
	done;

	mv output $class_grade
	echo " DONE. "
done;

rm output
echo "EXITING CALRADE UTILITY..."

