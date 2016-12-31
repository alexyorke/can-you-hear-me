#!/bin/bash

# Configuration

# How long you wish to record audio for at a time (s for seconds, m for minutes, h for hours)
audioCaptureDuration="30s"

# Where to save the volume adjustments
volumeLocation="$HOME/can-you-hear-me/volume.txt"

# Which output device to choose (change if it doesn't work)
outputDevice="auto"

# End configuration

outputDevices="$(pacmd list-sinks | grep -e 'name:' -e 'index' -e 'Speakers' | grep 'name')"
numberOfOutputDevices=$(echo "$outputDevices" | wc -l)

if [ "$outputDevice" == "auto" ]; then
	if (( numberOfOutputDevices > 1 )); then
		echo "Warning: You have the following output devices: $outputDevices . I'll select the first one by default, but you should change it in the configuration settings."
		outputDevices=$(echo "$outputDevices" | head -n 1)
	elif (( numberOfOutputDevices == 0 )); then
		echo "Error: I can't find any output devices."
		exit
  fi
fi

# put current date in file
"date" >> "$volumeLocation"

parec -d $(echo "$outputDevices" |                             # get the name of it
cut -d '<' -f 2 | 
cut -d '>' -f 1).monitor |                                     # format the name so it works with lame
(timeout $audioCaptureDuration lame -r -V0 -) |                # record for X seconds to stdout
ffmpeg -i pipe:0 -af "volumedetect" -f null /dev/null 2>&1 |   # pipe audio to ffmpeg, get mean volume in dB
grep "mean_volume" | 
rev | cut -d " " -f 1-2 | rev >> "$volumeLocation"             # extract dB from output; save to file

# Credits

# http://unix.stackexchange.com/questions/89571/how-to-get-volume-level-from-the-command-line
# http://superuser.com/questions/323119/how-can-i-normalize-audio-using-ffmpeg
# http://askubuntu.com/questions/229352/how-to-record-output-to-speakers
