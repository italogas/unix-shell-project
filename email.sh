#/bin/bash

#
# Sends an email to every student in a class-list 
# 

CLASS_NAME_REGEX="^[a-zA-Z][a-zA-Z][a-zA-Z]*[0-9][0-9][0-9][0-9]*[_][0-9][0-9]$"

#Check for right number of arguments
if [ "$#" -lt 2 ] ; then
	echo "Usage: email [ class-name ] [ message ]"
	echo "EXITING EMAIL UTILITY..."
	exit 1
fi

MESSAGE=$BASH_ARGV
#Tests is message file exists
if [ ! -f $MESSAGE ] ; then
	echo "FILE: $MESSAGE DOESN'T EXIST. EXITING EMAIL UTILITY..."
	exit 1
fi

#Checks if class exists 
IFS=$'\r\n' GLOBIGNORE='*' :; CLASSES=($(cat class-list))
while [ $# != 1 ]
do
	CLASS_FOUND_FLAG=0
	class=$1	
	#Checks if class name is a valid identifier
	if [[ ! "$class" =~ $CLASS_NAME_REGEX ]] ; then
		echo "CLASS NAME: $class NOT VALID. "
		shift
		continue
	fi

	for i in ${CLASSES[@]}; do

		if [ $i == $class ] ; then
			CLASS_FOUND_FLAG=1
			break;
		fi
	done;

	if [ $CLASS_FOUND_FLAG == 0 ] ; then
		echo "CLASS: $class NOT FOUND."
	else
		echo "PROCESSING $class ..."
		awk -F: '$4 != "" { print $4 }' $class >> email_list 

		IFS=$'\r\n' GLOBIGNORE='*' :; EMAILS=($(cat email_list ))
	        for email in ${EMAILS[@]}; do
			#send mail here
			echo "SENDING EMAIL TO: $email"
			sendmail $email < $MESSAGE 
       	        done; 
		echo "" > email_list
	fi

	shift
done

if [ -f email_list ] ; then
	rm email_list
fi

echo "EXITING EMAIl UTILITY..."

