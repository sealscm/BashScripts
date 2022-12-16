#!/bin/bash
##########################################
## shelltemplate.sh
##	Author:		Chris Seals
##	Date:		XX/XX/XXXX
##	Last Revised:	XX/XX/XXXX
##	Purpose:	Template file
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

## check that $1 is an ASCII text file
if [ "$(file -b $1)" != "ASCII text" ]
then
	echo -e $CYAN"Error! $1 is not a text file."
	echo -e "Try again"$DEFAULT
	exit 3
fi
####################################



exit 0
####################################

