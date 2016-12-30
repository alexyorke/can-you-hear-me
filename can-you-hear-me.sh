#!/bin/bash

# Configuration

# How long you wish to record audio for at a time (s for seconds, m for minutes, h for hours)
let audioCaptureDuration = "30s"

# Where to save the temporary file
let tempFileLocation = "/tmp/out"

# Where to save the volume adjustments
let volumeLocation = "~/can-you-hear-me/volume.txt"

# End configuration

echo $(date) >> '$volumeLocation'

# record output audio from first output device for x seconds, converting it to wav format
timeout $audioCaptureDuration parec -d $(pacmd list-sinks | grep -e 'name:' -e 'index' -e 'Speakers' | grep "name" | cut -d "<" -f 2 | cut -d ">" -f 1).monitor | lame -r -V0 - '$tempFileLocation'.wav

# ffmpeg gets the average decibels from sound, puts it in the historical volumes file
ffmpeg -i '$tempFileLocation'.wav -af "volumedetect" -f null /dev/null 2>&1 | grep "mean_volume" | rev | cut -d " " -f 1-2 | rev >> '$volumeLocation'

# trash the file
rm '$tempFileLocation'.wav

# Credits

# http://unix.stackexchange.com/questions/89571/how-to-get-volume-level-from-the-command-line
# http://superuser.com/questions/323119/how-can-i-normalize-audio-using-ffmpeg
# http://askubuntu.com/questions/229352/how-to-record-output-to-speakers
