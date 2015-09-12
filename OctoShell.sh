#!/bin/bash


if [ $# -lt 1  ]
then
	printf "\n\n./OctoShell.sh (status|upload *.gcode|uploadprint *.gcode)\n\n"
	exit 1
fi

source $(dirname "${BASH_SOURCE[0]}")/printer.cfg

if [ $1 == "status" ]
then

x=$(curl -s -H "X-Api-Key: $api_key" $printer/printer | grep -E "(text|actual|target)" | cut -d":" -f 2 | sed "s/\"//g;s/,//g;s/ //g")

state=$(echo "$x" | head -n 1)

bed1=$(echo "$x" | head -n 2 | tail -n 1)
bed2=$(echo "$x" | head -n 3 | tail -n 1)

he1=$(echo "$x" | head -n 4 | tail -n 1)
he2=$(echo "$x" | head -n 5 | tail -n 1)


x=$(curl -s -H "X-Api-Key: $api_key" $printer/job | grep -E "(completion|printTime|printTimeLest)")

comp=$(echo "$x" | head -n 1 | grep -o "[0-9]*\.[0-9][0-9]")
time=$(echo "$x" | head -n 2 | tail -n 1 | grep -o "[0-9]*")
time_left=$(echo "$x" | head -n 3 | tail -n 1 | grep -o "[0-9]*")



printf "\n Time: `date +"%H:%M:%S"`\nState: $state $comp %%\n  Bed:  $bed1 /  $bed2\n   HE: $he1 / $he2\n Time: `date -d@$time -u +%H:%M:%S` / `date -d@$time_left -u +%H:%M:%S`\n"

fi


if [ $1 == "upload" ]
then
	shift
	for f in "$@"
	do
		curl -H "X-Api-Key: $api_key" -F select=false -F print=false -F file=@$f "$printer/files/local" 
	done
fi

if [ $1 == "uploadprint" ]
then
	shift
	curl -H "X-Api-Key: $api_key" -F select=true -F print=true -F file=@$1 "$printer/files/local" 
fi


exit 0
