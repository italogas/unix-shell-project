#/bin/bash

#
# Adds grades of students to database  
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"
GRADE_REGEX="^[0-9][0-9][0-9]*$"
POLICY_REGEX="^[0-9][0-9]*$"

CLASS_FOUND_FLAG=0

checkPolicy() {
	policy=$1
	if [[ ! "$policy" =~ $POLICY_REGEX ]] ; then
		echo "INVALID POLICY. EXITING GRADEREPORT UTILITY..."
		exit 1
	fi
}

#Check for right number of arguments
if [ "$#" != 1 ] ; then
	echo "Usage: gradereport [ class-name ]"
	echo "EXITING GRADEREPORT UTILITY..."
	exit 1
fi

class=$1

#Checks if class name is a valid identifier
if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING GRADEREPORT UTILITY..."
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
	echo "CLASS NOT FOUND. EXITING GRADEREPORT UTILITY..."
	exit 1
fi

class_grade=$( echo "$class-G" )
if [ ! -f $class_grade ] ; then
	echo "CLASS GRADE FILE NOT FOUND. EXITING GRADEREPORT UTILITY..."
	exit 1
fi

class_grade_policy=$( echo "$class-G-P" )
if [ -f $class_grade_policy ] ; then
	echo "CLASS POLICY FILE ALREADY EXISTS. OVERRIDE EXISTENT FILE? (y/n)"
	read _a
	_a=$( echo $_a | awk '{print toupper($0)}' )
	if [ $_a == "N" ] ; then
		echo "EXITING GRADEREPORT UTILITY..."
		exit 1
	fi
fi

className=$( echo $class | awk '{print toupper($0)}' )

#Initial prompt   
echo "ENTER $className POLICY, "
echo "HOMEWORK: "
read hw_policy 
checkPolicy $hw_policy
echo "EXAMS: "
read exam_policy 
checkPolicy $exam_policy
echo "QUIZS: "
read qz_policy 
checkPolicy $qz_policy
echo "PROJECT: "
read project_policy 
checkPolicy $project_policy

echo "DO YOU LIKE TO CURVE? (y/n)"
read option
option=$( echo $option | awk '{print toupper($0)}' )
if [[ $option != "Y" && $option != "N"  ]] ; then
	echo "INVALID OPTION. EXITING ADDGRADE UTILITY..."
	exit 1
fi

echo
echo
echo "A  .......... 96-100" 
echo "A- .......... 91-95" 
echo "B+ .......... 85-90" 
echo "B  .......... 81-85" 
echo "B- .......... 76-80" 
echo "C+ .......... 71-75" 
echo "C  .......... 66-70" 
echo "C- .......... 61-65" 
echo "D+ .......... 56-60" 
echo "D  .......... 00-55" 
echo "D- .......... 00-55" 
echo "F  .......... 00-55" 

echo
echo "HOW DO YOU LIKE TO CURVE? (1/2)"
echo "1. ADD POINTS"
echo "2. ADD (100 - HIGHEST GRADE) POINTS TO ALL STUDENTS"
echo "ENTER YOUR OPTION: "
read answer
if [[ $answer != 1 && $answer != 2  ]] ; then
	echo "INVALID OPTION. EXITING GRADEREPORT UTILITY..."
	exit 1
fi

if [[ $answer == 1 ]] ; then
	echo "HOW MANY POINTS: "
	read points 
fi

if [[ $answer == 2 ]] ; then
	points=100 
fi

echo
echo "ALL GRADES WILL BE CURVED WITH $points. CONTINUE? (y/n)."
read answer2

answer2=$( echo $answer2 | awk '{print toupper($0)}' )
if [[ $answer2 != "Y" && $answer2 != "N"  ]] ; then
	echo "INVALID OPTION. EXITING GRADEREPORT UTILITY..."
	exit 1
fi

if [[ $answer2 == "N" ]] ; then
	echo "EXITING GRADEREPORT UTILITY..."
	exit 1
fi

echo
echo "CALCULATING THE FINAL GRADES..."

class_grade=$( echo "$class-G" )
IFS=$'\r\n' GLOBIGNORE='*' :; RECORDS=($(cat $class_grade))
first_line=${RECORDS[0]}
echo $first_line:GRADE:CURVE:LETTER > $class_grade_policy

awk -v hm="$hm_policy" -v qz="$qz_policy" -v ex="$ex_policy" -v pj="$pj_policy" -v c="$points" -F: 'NR != 1 { OFS=":"; print $0,grade= ($10*hm+$11*qz+$12*ex+$13*pj) * 1/100, grade+c }' $class_grade >> $class_grade_policy 

echo "THE GRADES ARE CALCULATED AND SAVED ..."

