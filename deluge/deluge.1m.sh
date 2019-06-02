#!/bin/sh
config_dir="$HOME/Developer/bitbar/config-files"
source "$config_dir/deluge.conf.sh"

# make temporary file to use for deluge-console output
tmpfile=$(mktemp)
tmpfile2=$(mktemp)

# variables
downloading_only=true
filter_words='REPACK iNTERNAL MULTi Repack'
deluge_console="/Applications/Deluge.app/Contents/MacOS/deluge-console"
connect="connect $deluge_ip_address $deluge_username $deluge_password"

filter=''
for word in $filter_words
do
    if [ ! -z $filter ]
    then
        filter="$filter|$word"
    else
        filter="$word"
    fi
done

if $downloading_only
then
    info_options="-s Downloading"
else
    info_options=""
fi

/Applications/Deluge.app/Contents/MacOS/deluge-console "connect $deluge_ip_address $deluge_username $deluge_password; info $info_options; exit" > $tmpfile
echo "" >> $tmpfile

summary=$(cat $tmpfile | grep State | cut -d' ' -f2 | sort | uniq -c | awk '{printf("%c%s/", $2, $1)}' | sed 's/\(.*\)\//\1/')

echo "\033[1;30m[tor:$summary]\033[37m"

while read line
do
    line_item=$(echo $line | awk -F ': ' '{print $1}')
    line_value=$(echo $line | awk -F ': ' '{print $2}')
    line_value2=$(echo $line | awk -F ': ' '{print $3}')
    line_value3=$(echo $line | awk -F ': ' '{print $4}')
    line_value4=$(echo $line | awk -F ': ' '{print $5}')
    if [ "$line_item" == "Name" ]
    then
        name=$line_value
        clean_name=$(echo "$line_value" | awk -F "720p" '{print $1}' | awk -F "1080p" '{print $1}' | sed -E "s/$filter//g" | sed "s/\./ /g")
        clean_name=$(echo "$clean_name" | awk '{print toupper(substr($0,0,1))substr($0,2)}')
    elif [ "$line_item" == "ID" ]
    then
        id=$line_value
    elif [ "$line_item" == "State" ]
    then
        if [ "$(echo "$line_value" | cut -c-11)" == "Downloading" ]
        then
            state=$(echo $line_value | sed 's/Down Speed//g')
            down_speed=$(echo $line_value2 | sed 's/Up Speed//g')
            up_speed=$(echo $line_value3 | sed 's/ETA//g')
            eta=$line_value4
        else
            state=$(echo $line_value | sed 's/Up Speed//g')
            up_speed=$line_value2
        fi
    elif [ "$line_item" == "Seeds" ]
    then
        seeds=$(echo $line_value | sed 's/Peers//g')
        peers=$(echo $line_value2 | sed 's/Availability//g')
        availability=$line_value3
    elif [ "$line_item" == "Size" ]
    then
        size=$(echo $line_value | sed 's/Ratio//g')
        ratio=$line_value2
    elif [ "$line_item" == "Seed time" ]
    then
        seed_time=$(echo $line_value | sed 's/Active//g')
        active=$line_value2
    elif [ "$line_item" == "Tracker status" ]
    then
        tracker=$line_value
        tracker_status=$(echo $line | cut -d':' -f3-)
    elif [ "$line_item" == "Progress" ]
    then
        progress=$line_value
    else
        if [ ! -z "$name" ]
        then
            output="$name|$clean_name|$id|$state|$down_speed|$up_speed|$eta|$seeds|$peers"
            output="$output|$availability|$size|$ratio|$seed_time|$active|$tracker|$tracker_status|$progress"
            echo "$output" >> $tmpfile2
            name=""
            id=""
            state=""
            down_speed=""
            up_speed=""
            eta=""
            seeds=""
            peers=""
            availability=""
            size=""
            ratio=""
            seed_time=""
            active=""
            tracker=""
            tracker_status=""
            progress=""
        fi
    fi
done < $tmpfile

echo "$(sort -t'|' -k4,4 -k2,2 $tmpfile2)" > $tmpfile2

previous_state=""
while read line
do
    name=$(echo "$line" | awk -F '|' '{print $1}')
    clean_name=$(echo "$line" | awk -F '|' '{print $2}')
    id=$(echo "$line" | awk -F '|' '{print $3}')
    state=$(echo "$line" | awk -F '|' '{print $4}')
    down_speed=$(echo "$line" | awk -F '|' '{print $5}')
    up_speed=$(echo "$line" | awk -F '|' '{print $6}')
    eta=$(echo "$line" | awk -F '|' '{print $7}')
    seeds=$(echo "$line" | awk -F '|' '{print $8}')
    peers=$(echo "$line" | awk -F '|' '{print $9}')
    availability=$(echo "$line" | awk -F '|' '{print $10}')
    size=$(echo "$line" | awk -F '|' '{print $11}')
    ratio=$(echo "$line" | awk -F '|' '{print $12}')
    seed_time=$(echo "$line" | awk -F '|' '{print $13}')
    active=$(echo "$line" | awk -F '|' '{print $14}')
    tracker=$(echo "$line" | awk -F '|' '{print $15}')
    tracker_status=$(echo "$line" | awk -F '|' '{print $16}')
    progress=$(echo "$line" | awk -F '|' '{print $17}')
    if [ "$previous_state" != "$state" ]
    then
        echo "---"
        echo "$state"
        echo "---"
        previous_state=$state
    fi
    echo "$clean_name"
    echo "--Name: $name"
    echo "--ID: $id"
    echo "--State: $state"
    if [ ! -z "$down_speed" ]
    then
        echo "--Down Speed: $down_speed"
    fi
    if [ ! -z "$up_speed" ]
    then
        echo "--Up Speed: $up_speed"
    fi
    if [ ! -z "$eta" ]
    then
        echo "--ETA: $eta"
    fi
    if [ ! -z "$seeds" ]
    then
        echo "--Seeds: $seeds"
    fi
    if [ ! -z "$peers" ]
    then
        echo "--Peers: $peers"
    fi
    if [ ! -z "$availability" ]
    then
        echo "--Availability: $availability"
    fi
    echo "--Size: $size"
    echo "--Ratio: $ratio"
    echo "--Seed Time: $seed_time"
    echo "--Active: $active"
    echo "--Tracker: $tracker"
    echo "--Tracker Status: $tracker_status"
    if [ ! -z "$progress" ]
    then
        echo "--Progress: $progress"
    fi
    echo "-----"
    if [ "$state" == "Paused" ]
    then
        echo "--Resume"
    else
        echo "--Pause"
    fi
done < $tmpfile2

echo "---"
echo "Refresh | refresh=true"
