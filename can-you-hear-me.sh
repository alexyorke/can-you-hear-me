#!/bin/bash

mkdir -p ~/can-you-hear-me

echo $(date) >> ~/can-you-hear-me/volumes.txt

# record output audio from first output device for five seconds, converting it to wav format
timeout 5s parec -d $(pacmd list-sinks | grep -e 'name:' -e 'index' -e 'Speakers' | grep "name" | cut -d "<" -f 2 | cut -d ">" -f 1).monitor | lame -r -V0 - /tmp/out.wav

# ffmpeg gets the average decibels from sound, puts it in the historical volumes file
ffmpeg -i /tmp/out.wav -af "volumedetect" -f null /dev/null 2>&1| grep "mean_volume" | rev | cut -d " " -f 1-2 | rev >> ~/can-you-hear-me/volumes.txt

# trash the file
rm /tmp/out.wav
