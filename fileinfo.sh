#!/bin/bash
##########################################
## fileinfo.sh
##	Author:		Chris Seals
##	Date:		11/02/2022
##	Last Revised:	11/02/2022
##	Purpose:	Outputs information about text files
##
##########################################

# colored text
DEFAULT="\e[39m"
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
PURPLE="\e[35m"
CYAN="\e[36m"
HORIZ_LINE="============================"

##	Error checking	###########
if [[ $# -ne 1 ]];
then
	echo -e $RED"** Usage: "
	echo -e "[path-to/]<fileinfo.sh> [path-to/]<input_file>"
	echo -e "**"$DEFAULT
	exit 1
fi

## check if file exists
if [ ! -f "$1" ]
then
	echo -e $CYAN"* $1 doesn't exist! *"$DEFAULT
	exit 1
fi

## check that $1 is an ASCII text file
if [ "$(file -b $1)" != "ASCII text" ]
then
	echo -e $CYAN"Error! $1 is not a text file."
	echo -e "Try again"$DEFAULT
	exit 3
fi
####################################

# get delimiter from user
read -p "Delimiter? "
delimiter="$REPLY"

#script-specific variables
count=1
lines=$(wc $1 | tr -s ' ' | cut -d' ' -f2)
words=$(sed "s/$delimiter/ /g" $1 | wc | tr -s ' ' | cut -d' ' -f3)
characters=$(wc $1 | tr -s ' ' | cut -d' ' -f4)

printf "%s\n" $1
printf "$HORIZ_LINE\n"

while read line # read in a line
do
	# count $line's characters
	chars=$(wc -c <<< $line | cut -d' ' -f1)
	if [[ $chars -ne 1 ]]; then # if more than one char
		printf "%s:\t$CYAN%s$PURPLE(%s chars)$DEFAULT\n\n" \
			"$count" "$line" "$chars"
	else # otherwise, it's an empty line
		printf "%s:\n" "$count"
	fi
	(( count++ )) # increment the counter
done < $1 # repeat until EOF

echo

printf "$HORIZ_LINE\n"
printf $GREEN"Lines:\t%s\n" "$lines"
printf "Words:\t%s\n" "$words"
printf "Chars:\t%s\n"$DEFAULT "$characters"
printf "$HORIZ_LINE\n\n"

exit 0
