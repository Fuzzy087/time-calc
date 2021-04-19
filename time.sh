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

}

iv_blank_days() {
#no blank fields allowed
	if [ -z "$sday" ] || [ -z "$eday" ]
        	then
                	printf "${red}Start date and/or end date cannot be left blank, please try again."
        	exit 0
	fi
}

iv_blank_times() {
	if [ -z "$stime" ] || [ -z "$etime" ]
		then
			printf "${red}Start time and/or end time cannot be left blank, please try again."
		exit 0
	fi

}

iv_blank_lunch() {
#no blank fields allowed
        if [ -z "$lunch" ]
                then
                        printf "${red}Lunch cannot be left blank, please try again. If you would like to deduct zero minutes, use the number 0."
                exit 0
        fi
}

iv_days() {
#Confirm the dates are formatted properly
	if ! [[ "$sday" =~ ^[01][0-9]-[0123][0-9]-202[0-9]$ ]] || ! [[ "$eday" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
        	then
                	printf "Starting day or Ending day is formatted incorrectly.\nCurrent format:\nStarting Day: $(echo "$sday")\nEnding Day: $(echo "$eday")\n\nCorrect format: MM-DD-YYYY\nExample: August 19th, 2021 would be - 08-19-2021\n"
        exit 0
fi

}

iv_times() {
#Confirm the times are formatted properly
        if ! [[ "$stime" =~ ^[0-9]{2}:[0-9]{2}$  ]] || ! [[ "$etime" =~ ^[0-9]{2}:[0-9]{2}$ ]]
                then
                        printf "Start time and/or End time needs to be a number\nCurrent start time:$(echo ${stime})\nCurrent end time:$(echo ${etime})\nCorrect Format:\nStart time: 14:45\nEnd time: 23:30"
                exit 0
        fi
}

iv_lunch() {
#Confirm the lunch is formatted correctly
	if ! [[ "$lunch" =~ ^[0-9]+$ ]]
		then
			printf "Lunch needs to be a number\nCurrent input: $(echo ${lunch})\nExample: 30\n"
		exit 0
	fi	
}

get_days() {
#get the starting day
	read -p "Enter the start date (MM-DD-YYYY): " sday

#get the ending day
	read -p "Enter the ending date, press [Enter] if same as starting date: " input
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
}

get_lunch() {
#get the number of minutes for lunch
read -p "Enter the number of minutes to deduct for lunch: " lunch
}

#Do all the functions
setup_env
get_days
iv_blank_days
iv_days
get_times
iv_blank_times
iv_times
get_lunch
iv_blank_lunch
iv_lunch


epoch_convert() {
	#Convert clock-in time to epoch
	epoch_stime=$(date -jf "%m-%d-%Y %H:%M" "${sday} ${stime}" +%s)

	#Convert clock-out time to epoch
	epoch_etime=$(date -jf "%m-%d-%Y %H:%M" "${eday} ${etime}" +%s)

	#Difference in seconds between epoch clock-in and epoch clock-out
	diff_time=$(expr ${epoch_etime} - ${epoch_stime})

	#Convert lunch minutes to seconds
	slunch=$(awk "BEGIN {print ${lunch}*60}")

	#Deduct the number of minutes for lunch
	total_time=$(awk "BEGIN {print ${diff_time}-${slunch}}")

	#Calculate the final total
	total_hours=$(awk -v OFMT="%5.2F%" "BEGIN {print ${total_time}/60/60}")

}

epoch_convert

#Pretty print totals
printf "${bold}${uline}Start date:${reset}|${green}${sday}${reset}\n${bold}${uline}End date:${reset}|${red}${eday}${reset}\n${bold}${uline}Clock-in time:${reset}|${green}${stime}${reset}\n${bold}${uline}Clock-out time:${reset}|${red}${etime}${reset}\n${bold}${uline}Lunch Minutes:${reset}|${red}${lunch}${reset}\n${bold}${uline}Total hours:${reset}|${bold}${blue}${total_hours}${reset}\n" | column -s '|' -t
