#!/bin/bash

# Configuration

# How long you wish to record audio for at a time (s for seconds, m for minutes, h for hours)
audioCaptureDuration="30s"

# Where to save the volume adjustments
volumeLocation="$HOME/can-you-hear-me/volume.txt"

# End configuration

"date" >> "$volumeLocation"

parec -d "$(pacmd list-sinks |                                  # list all audio sinks
grep -e 'name:' -e 'index' -e 'Speakers' |                      # choose the output speakers
grep 'name' |                                                   # get the name of it
cut -d '<' -f 2 | 
cut -d '>' -f 1)".monitor |                                     # format the name so it works with lame
(timeout $audioCaptureDuration lame -r -V0 -) |                 # record for X seconds to stdout
ffmpeg -i pipe:0 -af "volumedetect" -f null /dev/null 2>&1 |    # pipe audio to ffmpeg, get mean volume in dB
grep "mean_volume" | 
rev | cut -d " " -f 1-2 | rev >> "$volumeLocation"              # extract dB from output; save to file

# Credits

# http://unix.stackexchange.com/questions/89571/how-to-get-volume-level-from-the-command-line
# http://superuser.com/questions/323119/how-can-i-normalize-audio-using-ffmpeg
# http://askubuntu.com/questions/229352/how-to-record-output-to-speakers
