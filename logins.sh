#!/bin/bash
#################################################
## 	File Name:		project1.sh
##	Author:			Chris Seals
##	Date:			11/16/2022
##	Last Revised:	11/17/2022
##	Purpose:		Script to output all users 
##					and their number of logins.
##
#################################################

# colored text
DEFAULT="\e[39m"
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
PURPLE="\e[35m"
CYAN="\e[36m"
HORIZ_LINE="======================================================================"

# CODE BEGINS ########################

echo -e $RED"Calculating login information..."$DEFAULT

# Get users and number of logins, then put those into a variable
users=$( \
last -w | \
head -n -2 | \
tr -s " " | \
cut -d" " -f1 | \
grep -Ev "jack|ramseyjw|root|reboot" | \
sort | \
tail -n +2 | \
uniq -c | \
tr -s " ")

# Read lines one by one from previous command
printf "$PURPLE%5s  %-10s %-15s   %5s%-15s\n$DEFAULT" "#" " " "id" " " "name"
echo -e $PURPLE"$HORIZ_LINE"$DEFAULT
count=1
while read line
do
	# get number of logins from current line
	logins=$(echo "$line" | cut -d" " -f1)
	# get the id of the current line
	id=$(echo "$line" | cut -d" " -f2)
	# find the actual name paired with the id from the current line
	name=$(grep "$id" /etc/passwd | cut -d":" -f5 | cut -d"," -f1)

	# if statement for alternating colors for lines
	if [ $(( count % 2 )) == 1 ]
	then
		printf "$GREEN%5s. %-5s %-20s : %-20s\n$DEFAULT" "$count" "$logins" "$id" "$name"
	else
		printf "$CYAN%5s. %-5s %-20s : %-20s\n$DEFAULT" "$count" "$logins" "$id" "$name"
	fi

	(( count ++ ))
done <<< "$users"

# end of script
exit 0

####################################