#!/bin/bash
#################################################################
## students2json.sh
## 	Author:		    Chris Seals
## 	Date: 		    November 9, 2022
## 	Last revised:	November 9, 2022
## 	Purpose: 	    JSON-ify students2.txt file. students2.txt is a 
##                "+" delimited file.
#################################################################
##  Data fields:            variable name
##    1.  id                  id
##    2.  first name          first_name
##    3.  last name           last_name
##    4.  date of birth       dob
##    5.  email               email
##    6.  phone               phone
##    7.  city                city
##    8.  state               state
##    9.  standing            standing
##    10. major               major
##    11. years enrolled      years_enrolled
#################################################################
##    Other variables
##    FN    - Name of output file
##    TAB   - Series of spaces used for tabbing output
##    COUNT - Record counter
##    
##    
#################################################################
## JSON objects are formated like this:
##  {
##    "key1": "value1",
##    "key2": "value2",
##    "key3": "value3",
##    "key-n": "value-n"
##  }
##
##  JSON files are (usually) arrays of JSON objects, so
##  [
##    json_object,
##    json_object,
##    json_object,
##    json_object
##  ]
##
## Note the last object isn't followed by a comma
#################################################################
##
##    Error checking  ###################
# check for parameter
if [[ $# -ne 1 ]]; then
  echo " Usage: [path-to/]fileinfo.sh [path-to/]input_file"
  exit 1
fi

# check that input file exists
if [[ ! -f "$1" ]]
then
  echo "$1 does not exist! Check the file name"
  exit 2
fi

# check that file is ASCII or CSV text
if [[ "$(file -b $1)" != "ASCII text" && "$(file -b $1)" != "CSV text" ]] 
then
  echo "$1 is not a text file!"
  exit 3
fi
#########################################

# Variables #############################
FN=$(echo $1 | sed "s/txt/json/") # output file
TAB="  " # tabs for output
COUNT=0 # loop counter

# get rid of existing copy of students2.json
if [ -f $FN ]
then
  echo
  echo "--> Removing old copy of $FN"
  sleep 1
  echo "--> Done!"
  sleep 1
  echo
  rm $FN
fi

# begin output file
printf "[\n" > $FN

# display status bar to indicate that the script is working
printf "Working [*"

# main loop
while read -r line
do
  (( COUNT++ ))
  id=$(cut -d+ -f1 <<< $line)
  first_name=$(cut -d+ -f2 <<< $line)
  last_name=$(cut -d+ -f3 <<< $line)
  dob=$(cut -d+ -f4 <<< $line)
  email=$(cut -d+ -f5 <<< $line)
  phone=$(cut -d+ -f6 <<< $line)
  city=$(cut -d+ -f7 <<< $line)
  state=$(cut -d+ -f8 <<< $line)
  standing=$(cut -d+ -f9 <<< $line)
  major=$(cut -d+ -f10 <<< $line)
  years_enrolled=$(cut -d+ -f11 <<< $line)

# the first line of the file needs to be discarded
if [[ $id == "id" ]]
then
  (( COUNT-- ))
  continue
fi

  # print each line of the json object
  printf "$TAB{\n" >> $FN # opening brace
  # JSON format for each line is '"key": "value",'
  # template: printf "$TAB$TAB\"\": \"\",\n" >> $FN
  printf "$TAB$TAB\"record_number\": \"$COUNT\",\n" >> $FN # record number
  printf "$TAB$TAB\"id\": \"$id\",\n" >> $FN # term number
  printf "$TAB$TAB\"first_name\": \"$first_name\",\n" >> $FN # first name
  printf "$TAB$TAB\"last_name\": \"$last_name\",\n" >> $FN # last name
  printf "$TAB$TAB\"dob\": \"$dob\",\n" >> $FN # date of birth
  printf "$TAB$TAB\"email\": \"$email\",\n" >> $FN # email
  printf "$TAB$TAB\"phone\": \"$phone\",\n" >> $FN # phone
  printf "$TAB$TAB\"city\": \"$city\",\n" >> $FN # city
  printf "$TAB$TAB\"state\": \"$state\",\n" >> $FN # state
  printf "$TAB$TAB\"standing\": \"$standing\",\n" >> $FN # standing
  printf "$TAB$TAB\"major\": \"$major\",\n" >> $FN # major
  printf "$TAB$TAB\"years_enrolled\": \"$years_enrolled\"\n$TAB},\n" >> $FN # years enrolled
  # last record doesn't have a trailing comma. the closing } does (except for the last object - see below)
  
  # output "*'s" to show that the script is working
  if ! (( COUNT % 50 ))
  then
    printf "*"
  fi

done < $1

truncate -s-2 $FN   # get rid of last comma (kills the newline also, but then add it back after)

# add newline and closing ']'
printf "\n]\n" >> $FN

# epilog ################################
echo "] Done!"
sleep 1
echo "--> Displaying $FN (press 'q' to quit)\n"
sleep 5
clear

# display the file out to confirm
less $FN

exit 0