#/bin/bash

#
# Creates a student-list for a class 
# 

CURRENT_WORK_DIRECTORY=$(pwd)

#CLASS_NAME_REGEX="^[a-zA-Z]\{3, 4\}[_][0-9]\{3, 4\}$"
CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"

# Test for first execution
if [ ! -f "$CURRENT_WORK_DIRECTORY/class-list" ] ; then
	touch class-list
fi

# Checks if name given is valid
echo "ENTER CLASS NAME: " 
read class_name
while [[ ! "$class_name" =~ $CLASS_NAME_REGEX ]] 
do
	echo "CLASS NAME: $class_name INVALID. "
	echo 
	echo "ENTER CLASS NAME: " 
	read class_name
done

# awk '"$class_name" {print $0}' class-list ) == $class_name ] ; then

if [ -f "$CURRENT_WORK_DIRECTORY/$class_name" ] ; then
	echo "CLASS LIST $class_name ALREADY EXISTS. ADD NEW STUDENTS TO $class_name ? (Y/N)"
	read answer
	if [ "$answer" = "Y" ] || [ "$answer" = "y" ] ; then
		echo "STARTING ADD UTILITY... "
		source "add.sh"		
		if [ $? != 0 ] ; then
			echo "SOMETHING WENT WRONG. EXITING $0 UTILITY... "
			exit 1
		fi
	else
		echo "EXITING $0 UTILITY... "
		exit 1
	fi
else
	echo "CLASS LIST $class_name DOESN'T EXIST. CREATE NEW CLASS LIST NAMED $class_name ? (Y/N)"
	read answer
	if [ "$answer" = "Y" ] || [ "$answer" = "y" ] ; then
		echo "ADDING $class_name TO CLASS LIST... "
		touch "$class_name"
		echo $class_name >> class-list
	else
		echo "EXITING $0 UTILITY... "
		exit 1
	fi
fi


