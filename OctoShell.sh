#!/bin/bash

# ***** *****  controls ***** *****

# check arguments
if [ $# -lt 1  ]
then
	printf "\n\n./OctoShell.sh (status|upload *.gcode|uploadprint *.gcode)\n\n"
	exit 1
fi

# load config
source $(dirname "${BASH_SOURCE[0]}")/printer.cfg

# ***** *****  functions ***** *****

function do_status() {

        # query printer
        q1=$(curl -s -H "X-Api-Key: $api_key" $printer/printer)

        # parse arguments
        state=$(echo "$q1" | jq -r '.state.text')
        bed_actual=$(echo "$q1" | jq -r '.temperature.bed.actual')
        bed_target=$(echo "$q1" | jq -r '.temperature.bed.target')
        he_actual=$(echo "$q1" | jq -r '.temperature.tool0.actual')
        he_target=$(echo "$q1" | jq -r '.temperature.tool0.target')
        
        # query job
        q2=$(curl -s -H "X-Api-Key: $api_key" $printer/job)

        # parse arguments
        comp=$(echo "$q2" |  jq -r '.progress.completion' )
        time=$(echo "$q2" | jq -r '.progress.printTime' )
        time_left=$(echo "$q2" | jq -r '.progress.printTimeLeft')

        # NULL substitution
        if [ $comp == "null" ]; then comp="" ; else comp="$comp %%" ; fi
        if [ $time == "null" ]; then time=0 ; fi
        if [ $time_left == "null" ]; then time_left=0 ; fi


        printf "\tTime:\t`date +"%H:%M:%S"`\n"
        printf "\tState:\t$state $comp\n"
        printf "\tBed:\t$bed_actual /  $bed_target\n"
        printf "\tHE:\t$he_actual / $he_target\n"
        printf "\tTime:\t`date -d@$time -u +%H:%M:%S` / `date -d@$time_left -u +%H:%M:%S`\n"

        
}

function do_upload() {
	shift
	for f in "$@"
	do
		curl -H "X-Api-Key: $api_key" -F select=false -F print=false -F file=@$f "$printer/files/local" 
	done
}

function do_uploadprint() {
	shift
	curl -H "X-Api-Key: $api_key" -F select=true -F print=true -F file=@$1 "$printer/files/local" 
}

function do_getfiles() {

        q1=$(curl -s -H "X-Api-Key: $api_key" $printer/files/local | jq -r '.files[].name')
        printf "\n\n\tFiles in printer:\n\n"
        for f in $q1
        do
            printf "\t$f\n"
        done
        printf "\n\n"
}

function do_printfile() {

        q1=$(curl -s -H "X-Api-Key: $api_key" $printer/files/local | jq -r '.files[].name')
        printf "\n\n\tFiles in printer:\n\n"  
        declare -a x
        n=0
        for f in $q1
        do
            printf "\t$n) $f\n"
            x[$n]=$f
            ((n++))
        done
        printf "\n\n\tNumber of file to print: "
        read num_to_print
        
        curl -s -H "X-Api-Key: $api_key" -H "Content-Type: application/json" -X POST -d '{"command":"select","print":"false"}' $printer/files/local/${x[$num_to_print]} 

}


# ***** *****  main ***** *****

if [ $1 == "status" ]
then
    do_status
    
elif [ $1 == "upload" ]
then
    do_upload "$@"
    
elif [ $1 == "uploadprint" ]
then
    do_uploadprint "$@"


elif [ $1 == "list" ]
then
    do_getfiles
    

elif [ $1 == "print" ]
then
    do_printfile
    
    
fi

exit 0
