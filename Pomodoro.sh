#!/bin/bash

WORK=25
PAUSE=5
LONGBREAK=15
INTERACTIVE=true
AFTERBREAKCOMMAND=""

show_help() {
	cat <<-END
		usage: Pomodoro [-s] [-m] [-w m] [-b m] [-l m] [-h]
		    -s: simple output. Intended for use in scripts
		        When enabled, Pomodoro outputs one line for each minute, and doesn't print the bell character
		        (ascii 007)

		    -m: mute -- don't play sounds when work/break is over
		    -w m: let work periods last m minutes (default is 25)
		    -b m: let break periods last m minutes (default is 5)
		    -l m: set long break periods after 4 work periods (default is 15)
		    -c specify the command to excecute after a break period
		    -h: print this message
	END
}

while getopts sw:b:l:mc: opt; do
	case "$opt" in
		s)
			INTERACTIVE=false
			;;
		w)
			WORK=$OPTARG
			;;
		b)
			PAUSE=$OPTARG
			;;
		l)
			LONGBREAK=$OPTARG
			;;
		c)
			AFTERBREAKCOMMAND=$OPTARG
			;;
			h|\?)
			show_help
			exit 1
			;;
	esac
done

time_left="%im left of %s "

if $INTERACTIVE; then
	clear
	time_left="\r$time_left"
else
	time_left="$time_left\n"
fi

while true
do
	for c in 1 2 3 4 
	do
		for ((i=$WORK; i>0; i--))
		do
			printf "$time_left" $i "work"
			sleep 1m
		done


		if $INTERACTIVE; then
			echo -e "\a"
			printf "Work over"
			read
		fi

		if [ $c -ne 4 ]
		then
			for ((i=$PAUSE; i>0; i--))
			do
				printf "$time_left" $i "pause"
				sleep 1m
			done
		else
			for ((i=$LONGBREAK; i>0; i--))
			do
				printf "$time_left" $i "pause"
				sleep 1m
			done
		fi

		eval $AFTERBREAKCOMMAND

		if $INTERACTIVE; then
			echo -e "\a"
			printf "Pause over"
			read
		fi
	done
done
