#!/bin/bash

infile="$2"

area=$(grep -Eo "([0-9]{3}-){2}[0-9]{4}" $infile | sed -E "s/([0-9]{3})-([0-9]{3})-([0-9]{4})/\1/" | grep -c "$1")

printf "\n=================================\n"
printf "Students from area code $1: %s\n" "$area"
printf "=================================\n"

