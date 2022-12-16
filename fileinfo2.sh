#!/bin/bash
##########################################
## fileinfo2.sh
##	Author:		Chris Seals
##	Date:		11/02/2022
##	Last Revised:	11/02/2022
##	Purpose:	Display info about text files.
##			Menu based. Illustrates bash functions
##			& case statements. Uses test file
##			students.txt or students2.txt
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
	echo -e "[path-to/]<> [path-to/]<input_file>"
	echo -e "**"$DEFAULT
	exit 1
fi

## check if file exists
if [ ! -f "$1" ]
then
	echo -e $CYAN"* $1 doesn't exist! *"$DEFAULT
	exit 1
fi

## check that $1 is an ASCII or CSV text file
if [[ "$(file -b $1)" != "ASCII text" && "$(file -b $1)" != "CSV text" ]]
then
	echo -e $CYAN"Error! $1 is not a text file."
	echo -e "Try again"$DEFAULT
	exit 3
fi
####################################
read -p "Delimiter? "
delim="$REPLY"

lines=$(wc "$1" | tr -s ' ' | cut -d' ' -f2)
words=$(sed "s/$delim/ /g" "$1" | wc | tr -s ' ' | cut -d' ' -f3)
characters=$(sed "s/$delim/ /g" "$1" | wc | tr -s ' ' | cut -d' ' -f4)

# Functions
# Print header
function header ()
{
	clear
	printf $GREEN" $1\n"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"
}


# Pause output
function pause ()
{
	read -p "Enter to continue..."
}

# Display Menu
function display_menu ()
{
	clear
	printf $GREEN"	Menu\n"
	printf "%s\n" "$HORIZ_LINE"
	printf "# 1. Display all\n"
	printf "# 2. Display Summary info\n"
	printf "# 3. # of Lines\n"
	printf "# 4. # of Words\n"
	printf "# 5. # of Characters\n"
	printf "# 6. Exit\n"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"
}

# Display file & counts
function display_all()
{
	while read line
	do
		linechars=$(wc -c <<< $line | cut -d' ' -f1)
		if [ $linechars -ne 1 ]
		then
			printf "%s: $PURPLE(%s chars)\t$CYAN%s\t$DEFAULT\n\n" "$count" "$linechars" "$line"
		else
			printf "%s:\n\n" "$count"
		fi

		(( count ++ ))
	done < $1

	pause
	count=0
}

# Display only summary info
function display_summary()
{
	printf $GREEN"Lines:\t\t%s\n" "$lines"
	printf "Words:\t\t%s\n" "$words"
	printf "Chars:\t\t%s\n" "$characters"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"

	pause
}

# Display # of lines
function display_lines()
{
	printf $GREEN"Lines: \t\t%s\n" "$lines"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"

	pause
}

# Display # of words
function display_words()
{
	printf $GREEN"Words: \t\t%s\n" "$words"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"

	pause
}

# Display $ of characters
function display_characters()
{
	printf $GREEN"Chars: \t\t%s\n" "$characters"
	printf "%s\n"$DEFAULT "$HORIZ_LINE"

	pause
}

###> output <#######################
while true
do
	display_menu
	read -p "** Enter selection: "

	case $REPLY in
		1) header " Displaying $1"
			display_all $1
		;;
		2) header " Summary $1"
			display_summary
		;;
		3) header " # of Lines in $1"
			display_lines
		;;
		4) header " # of Words in $1"
			display_words
		;;
		5) header " # of Characters in $1"
			display_characters
		;;
		6) break
		;;
		*)	printf "Please enter a value between 1-6\n"
			pause
		;;
	esac
done


exit 0
####################################

