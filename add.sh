#/bin/bash

#
#  Adds students to class list 
# 

# valid number
RE='^[0-9]+$'
CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"
ONE_LINE_INSERTION_FLAG=0
NUMBEROF_EXECUTIONS=1
CLASS_FOUND_FLAG=0

# Special function used to sort student list
sortStudentList() {
	sort -t":" -k1,1 $class_name > temp
	cat temp > $class_name
	rm temp
}

#Checks if new student's key is valid 
checkNewEntry() {
	awk -v sid=$1 -F: '{ if ($3 == sid) print $0 }' $class_name > out 
}

#Check for right number of arguments
if [ "$#" -gt 3 ] ; then
	echo "Usage: add [-1l (add in one line) ] [-n (n=number of runs) ]"
	echo "EXITING ADD UTILITY..."
	exit 1
fi

if [ $# == 3 ] ; then
	class_name=$3
fi
if [ $# == 2 ] ; then
	class_name=$2
fi
#Checks if class name is a valid identifier
if [[ ! "$class_name" =~ $CLASS_NAME_REGEX ]] ; then
	echo "CLASS NAME NOT VALID. EXITING ADD UTILITY..."
	exit 1
fi

#Checks if class exists 
IFS=$'\r\n' GLOBIGNORE='*' :; CLASSES=($(cat class-list))
for i in ${CLASSES[@]}; do
	if [ $i == $class_name ] ; then
		CLASS_FOUND_FLAG=1
		break;
	fi
done

if [ $CLASS_FOUND_FLAG == 0 ] ; then
	echo "CLASS NOT FOUND. EXITING ADD  UTILITY..."
	exit 1
fi


#Checks the argument received
if [ $# == 2 ] ; then
	if [[ "$1" =~ "-1l" ]] ; then
		ONE_LINE_INSERTION_FLAG=1
	elif [[ "$1" =~ $RE ]] ; then
		NUMBEROF_EXECUTIONS=$1
	else
		echo "WRONG OPTION. EXITING ADD UTILITY..."
		exit 1
	fi
fi

if [ $# == 3 ] ; then
	if [ "$1" = "-1l" ] ; then
		ONE_LINE_INSERTION_FLAG=1
	else 
		echo "ONE LINE FLAG NOT VALID. EXITING ADD UTILITY..."
	        exit 1		
	fi
	if [[ "$2" =~ $RE ]] ; then
		NUMBEROF_EXECUTIONS=$2
	else
		echo "NUMBER OF EXECUTIONS IS NOT A VALID NUMBER. EXITING ADD UTILITY..."
		exit 1
	fi
fi

if [ $ONE_LINE_INSERTION_FLAG == 1 ] ; then
	j=0
	while [ $j -lt $NUMBEROF_EXECUTIONS ] 
	do
		echo "---------------------"
		echo "ENTER STUDENT $j: "
		read new_student
		echo $new_student >> $class_name
		j=$(( $j+1 ))
	done
	sortStudentList
	echo "NO MORE LINES TO INSERT. EXITING ADD UTILITY..."
	exit 0
fi

i=0
while [ $i -lt $NUMBEROF_EXECUTIONS ]
do
	echo "---------------------"
	echo "ENTER STUDENT $i: "
	echo "ENTER THE LAST NAME: "
	read last_name
	new_student="$last_name"
	echo "ENTER THE FIRST NAME: "
	read first_name
	new_student="$new_student:$first_name"
	echo "ENTER SID: "
	read sid
	new_student="$new_student:$sid"
	echo "ENTER EMAIL: "
	read email
	new_student="$new_student:$email"
	echo "ENTER PHONE NUMBER: "
	read phone_number
	new_student="$new_student:$phone_number"

	echo $new_student >> $class_name
	i=$(( $i+1 ))
done

sortStudentList

echo "NO MORE LINES TO INSERT. EXITING ADD UTILITY..."



