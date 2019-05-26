#!/bin/bash

# <bitbar.title>chunkwm/skhd helper</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Shi Han NG</bitbar.author>
# <bitbar.author.github>shihanng</bitbar.author.github>
# <bitbar.desc>Plugin that displays desktop id and desktop mode of chunkwm.</bitbar.desc>
# <bitbar.dependencies>brew,chunkwm,skhd</bitbar.dependencies>

# Info about chunkwm, see: https://github.com/koekeishiya/chunkwm
# For skhd, see: https://github.com/koekeishiya/skhd

export PATH=/usr/local/bin:$PATH

if [[ "$1" = "stop" ]]; then
    brew services stop chunkwm
    brew services stop skhd
elif [[ "$1" = "restart" ]]; then
    brew services restart chunkwm
    brew services restart skhd
fi

monitor_count=$(chunkc tiling::query --monitor count)
desktop_list=""
# echo "[$(chunkc tiling::query --desktop mode | cut -c 1-3):$(chunkc tiling::query --desktop id)]"

for i in $(seq 1 $monitor_count)
do
    desktop_list="$desktop_list $(chunkc tiling::query --desktops-for-monitor $i)"
    if [ $(chunkc tiling::query --desktop id) -eq 0 ] && [ $(chunkc tiling::query --monitor id) -eq $i ]
    then
        desktop_list="$desktop_list F"
    fi
done

desktop_list="${desktop_list/$(chunkc tiling::query --desktop id)/\e[30;47m$(chunkc tiling::query --desktop id)\e[0:40m\e[1;30m}"
desktop_list="${desktop_list/F/\e[30;47mFf(chunkc tiling::query --desktop idf(chunkc tiling::query --desktop id))\e[0:40m\e[1;30m}"

printf "\e[1;30m[$(chunkc tiling::query --desktop mode | cut -c 1-3):$desktop_list ] | ansi=true \n"

echo "---"
echo "Restart chunkwm & skhd | bash='$0' param1=restart terminal=false"
echo "Stop chunkwm & skhd | bash='$0' param1=stop terminal=false"

