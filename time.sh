#! /bin/bash

#Environment Setup
setup_env() {
	#set colors
	red=$(tput setaf 1)
	green=$(tput setaf 2)
	blue=$(tput setaf 4)
	reset=$(tput sgr0)

	#set formatting
	bold=$(tput bold)
	uline=$(tput smul)

	#reset the env to start with a clean slate
	reset
}

get_days() {
#get the starting day
read -p "Enter the start date (MM-DD-YYYY): " sday

#get the ending day
echo "Enter the ending date, press [Enter] if same as starting date: "
read input
if [[ $input == "" ]]; then
	eday=$sday
else
	eday=$input
fi
}

get_times() {
#get the clock-in time
printf "24-hour clock quick reference:\n7:00am -> 07:00\n-------\n3:00pm -> 15:00\n-------\n11:00pm -> 23:00\n-------\n" 
read -p "Enter the clock-in time (24-hour clock): " stime

#get the clock-out time
read -p "Enter the clock-out time (24-hour clock): " etime

#get the number of minutes for lunch
read -p "Enter the number of minutes to deduct for lunch: " lunch
slunch=$(awk "BEGIN {print ${lunch}*60}")
}

get_days
get_times
setup_env

validate_input() {
#Confirm everything the user entered is in the valid format stime etime lunch sday eday
if [ -z "$stime" ] || [ -z "$etime" ] || [ -z "$sday" ] || [ -z "$eday" ] || [ -z "$lunch" ]
	then
		printf "${red}Fields cannot be left blank, please try again."
	exit 0
fi

if ! [[ "$sday" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$eday" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
	then
		printf "Starting day or Ending day is formatted incorrectly.\nCurrent format:\n\tStarting Day: $(echo "$sday")\n\tEnding Day: $(echo "$eday")\n\nCorrect format: MM-DD-YYYY\nExample: 08-19-2021\n"
	exit 0
fi
}

validate_input 

epoch_convert() {
	#Convert clock-in time to epoch
	epoch_stime=$(date -jf "%m-%d-%Y %H:%M" "${sday} ${stime}" +%s)

	#Convert clock-out time to epoch
	epoch_etime=$(date -jf "%m-%d-%Y %H:%M" "${eday} ${etime}" +%s)

	#Difference in seconds between epoch clock-in and epoch clock-out
	diff_time=$(expr ${epoch_etime} - ${epoch_stime})

	#Deduct the number of minutes for lunch
	total_time=$(awk "BEGIN {print ${diff_time}-${slunch}}")

	#Calculate the final total
	total_hours=$(awk -v OFMT="%5.2F%" "BEGIN {print ${total_time}/60/60}")

}

epoch_convert

#Pretty print totals
printf "${bold}${uline}Start date:${reset}|${green}${sday}${reset}\n${bold}${uline}End date:${reset}|${red}${eday}${reset}\n${bold}${uline}Clock-in time:${reset}|${green}${stime}${reset}\n${bold}${uline}Clock-out time:${reset}|${red}${etime}${reset}\n${bold}${uline}Lunch Minutes:${reset}|${red}${lunch}${reset}\n${bold}${uline}Total hours:${reset}|${bold}${blue}${total_hours}${reset}\n" | column -s '|' -t
