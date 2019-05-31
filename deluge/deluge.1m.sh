#!/bin/sh
dir="$(dirname $(readlink $0))"
source "$dir/deluge.conf.sh"

filter_words='REPACK iNTERNAL MULTi Repack'

filter='Name:'
for word in $filter_words
do
    filter="$filter|$word"
done

downloading=$(/Applications/Deluge.app/Contents/MacOS/deluge-console "connect $deluge_ip_address $deluge_username $deluge_password; info -s Downloading; exit" | grep "Name: " |\
    awk '{FS="720p"}; {print $1}' | awk '{FS="1080p"}; {print $1}' |\
    sed -E "s/$filter//g" | sed "s/\./ /g" | awk '{$1=$1};1')


download_count=$(echo "$downloading" | wc -l | awk '{$1=$1}1;')

if [[ ! -z $downloading ]]
then
    echo "\033[1;30m[tor:$download_count]\033[37m"
    echo '---'
    echo "$downloading"

    echo '---'
    echo 'Refresh | refresh=true'
fi

