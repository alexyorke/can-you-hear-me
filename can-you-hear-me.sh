#!/bin/bash

# Configuration

# How long you wish to record audio for at a time (s for seconds, m for minutes, h for hours)
audioCaptureDuration="30s"

# Where to save the volume adjustments
volumeDB="$HOME/can-you-hear-me/volume.csv"

# Which output device to choose (change if it doesn't work)
outputDevice="auto"

# End configuration

outputDevices="$(pacmd list-sinks | grep -e 'name:' -e 'index' -e 'Speakers' | grep 'name')"
numberOfOutputDevices=$(echo "$outputDevices" | wc -l)

# Check if volume database exists; if not create it with a csv header
if [ ! -f "$volumeDB" ]; then
	echo "Date,Avg Output" >> "$volumeDB"
fi

# try to find a suitable output device
if [ "$outputDevice" == "auto" ]; then
	if (( numberOfOutputDevices > 1 )); then
		echo "Warning: You have the following output devices: $outputDevices . I'll select the first one by default, but you should change it in the configuration settings."
		outputDevices=$(echo "$outputDevices" | head -n 1)
	elif (( numberOfOutputDevices == 0 )); then
		echo "Error: I can't find any output devices."
		exit
  fi
fi

# get the average output volume
outputVolumeFormatted=$(parec -d $(echo "$outputDevices" |     # get the name of it
cut -d '<' -f 2 | 
cut -d '>' -f 1).monitor |                                     # format the name so it works with lame
(timeout $audioCaptureDuration lame -r -V0 -) |                # record for X seconds to stdout
ffmpeg -i pipe:0 -af "volumedetect" -f null /dev/null 2>&1 |   # pipe audio to ffmpeg, get mean volume in dB
grep "mean_volume" | 
rev | cut -d " " -f 1-2 | rev)             		       # extract dB from output; save to file

# get the output volume, and round it so that bash can use it
outputVolumeDb=$(echo "$outputVolumeFormatted" | cut -d " " -f 1 | awk '{print int($1+0.5)}')

if ((outputVolumeDb < -65 )); then
	echo "Warning: I didn't detect any sound. Make sure that your output device is correctly selected."
fi

date=$(date)

# write results to file
echo "$date,$outputVolumeFormatted" >> "$volumeDB"

# Credits

# http://unix.stackexchange.com/questions/89571/how-to-get-volume-level-from-the-command-line
# http://superuser.com/questions/323119/how-can-i-normalize-audio-using-ffmpeg
# http://askubuntu.com/questions/229352/how-to-record-output-to-speakers
# http://stackoverflow.com/questions/2395284/round-a-divided-number-in-bash
