#!/bin/bash
############################################################################
#	iplookup.sh
#	  Author:	    Chris Seals
#	  Date:		    18-Feb-2023
# 	  Last revised:	05-Mar-2023
#	  Description:	Identifies attempted hacking on the server
#			- Checks an input file for IP addresses
#			- Counts the number of attempts for each
#			- Discards IP addresses with <100 attempts
#			- Menu driven
#			  - 1. Displays IP addresses
#			  - 2. Displays detailed IP information
#			  - 3. Adds IP addresses to UFW
#			       - Makes sure IP addy isn't already in UFW
#			  - 4. Displays firewall rules
#			  - 5. Exits script
#
############################################################################

# colored text variables
COLOR="\033["
DEFAULT="${COLOR}0m"
RED="${COLOR}0;31m"
BLUE="${COLOR}0;34m"
GREEN="${COLOR}0;32m"
HORIZ_LINE="========================================"

############### ERROR CHECKING ######################
# check if user has sudo access to access log files #
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "\n\n\n${HORIZ_LINE} \n${GREEN}Usage: \`sudo iplookup.sh logfile.txt\` \n${RED}Please run this scipt with sudo access!${DEFAULT} \n${HORIZ_LINE} \nExiting with error code 1..."
    exit 1
fi

# check for proper usage (correct # of arguments - 0)
# if [[ $# != 0 ]]; then
#    echo -e "\n\n\n${HORIZ_LINE} \n${GREEN}Usage: \`sudo iplookup.sh\` \n${RED}There are no parameters for this script!${DEFAULT} \n${HORIZ_LINE} \nExiting with error code 2..."
#    exit 2
# fi

# check for parameters
if [[ $# != 1 ]]; then
    echo -e "\n\n\n${HORIZ_LINE} \n${GREEN}Usage: \`sudo iplookup.sh logfile.txt\` \n${RED}Please use a log file as a parameter for this script!${DEFAULT} \n${HORIZ_LINE} \nExiting with error code 2..."
    exit 2
fi

# checks if file from parameter exists
if  [[ ! -f "$1" ]]; then
    echo -e "\n\n\n${HORIZ_LINE} \n${GREEN}Usage: \`sudo iplookup.sh logfile.txt\` \n${RED}$1 does not exist \nPlease use an existing file for this script!${DEFAULT} \n${HORIZ_LINE} \nExiting with error code 3..."
    exit 3
fi

# checks if file is a text file
if [[ "$(file -b "$1")" != "ASCII text" ]]; then
    echo -e "\n\n\n${HORIZ_LINE} \n${GREEN}Usage: \`sudo iplookup.sh logfile.txt\` \n${RED}Unknown file type: $1 \nPlease use a txt file for this script!${DEFAULT} \n${HORIZ_LINE} \nExiting with error code 4..."
    exit 4
fi

############# DONE ERROR CHECKING ##################

#variables
LOOPCONTINUE=true
LOGFILE=$1
regs=0
attempts=0
uniqueIPs=0

#REGEX VAR(S) HERE
QUAD="(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"
IP="\b$QUAD\.$QUAD\.$QUAD\.$QUAD\b"

WHOLEIP="(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"

#get all offenders (100+) from input file. In the input file, the IP address
#is recorded three times for each offense.
#filtering on "rhost=$IP" trims off the other two entries

printf "Working... "

# This was my first attempt at this, but I thought it would be more effiecient not to do the same command 3 times...
# regs=$(grep -Eo "rhost=$IP" "$LOGFILE" | sort | uniq -c)
# attempts=$(grep -Eo "rhost=$IP" "$LOGFILE" | sort | wc -l)
# uniqueIPs=$(grep -Eo "rhost=$IP" "$LOGFILE" | sort | uniq | wc -l)

# This is a more efficient approach than what is above, because the variables attempts and uniqueIPs don't have to do the same command twice after it already happened...
regs=$(grep -Eo "rhost=$IP" "$LOGFILE" | sort)
attempts=$(wc -l <<< "$regs")
uniqueIPs=$(uniq <<< "$regs" | wc -l)

printf "Done!\n"

#display the unique IP addresses on demand
function display_unique_ips ()
{
    echo -e "${RED}"
    grep -Eo <<< "$regs" -e "$IP" | uniq
    echo -e "${DEFAULT}"
}

#print detailed info on the offenders
function print_info ()
{
    echo "Print info function"
}

#add the IPs to the firewall. if 'y', have to check
#and make sure that the IP isn't already in the firewall
function add_ips_to_ufw ()
{
    currentRules=$(sudo ufw status numbered)
    #Gets all IPs that failed connecting more than 100 times
    badIPs=$(grep -Eo <<< "$regs" -e "$IP" | uniq -c | sort | grep -E "[0-9]{3,} " | grep -Eo "$IP")

    while read ip; do
        grep -q "$ip" <<< "$currentRules"
        if [[ $? -eq 1 ]]; then
            printf "Adding %s..." $ip
            sudo ufw deny from $ip
            printf " Rule inserted\n"
        else
            echo -e "${RED}Already in UFW! -- ${ip}${DEFAULT}"
        fi
    done <<< "$badIPs"
}

function show_firewall ()
{
    sudo ufw status numbered | less
}

#count both total attempts and unique IP addresses
echo -e "\n${RED}There were ${attempts} total attempts from ${uniqueIPs} unique IP addresses${DEFAULT}"

#menu goes here (infinite loop)
while $LOOPCONTINUE; do

    #display menu
    echo -e "\n${HORIZ_LINE}${GREEN}"
    echo "1. Get unique IP addresses"
    echo "2. Show detailed information ('q' to quit)"
    echo "3. Add new offenders to UFW"
    echo "4. Show firewall rules ('q' to quit)"
    echo "5. Quit"

    #read response
    printf "\nChoose an option: "
    read -r RESPONSE
    echo -e "${DEFAULT}"
    clear -x
    
    #choose method based on response
    case "$RESPONSE" in
        1)
            display_unique_ips
        ;;
        2)
            print_info
        ;;
        3)
            add_ips_to_ufw
        ;;
        4)
            show_firewall
        ;;
        5)
            LOOPCONTINUE=false
        ;;
        *)
            echo "Uknown command, please enter 1-5 for the commands listed"
        ;;
    esac
done

###################################################################
echo
echo "Done! Bye now"
echo
