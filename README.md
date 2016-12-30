# can-you-hear-me
An app to predict and prevent hearing loss by measuring the output volume everyday. Over time, you can see how much the output volume level has increased (if at all.)

It cannot be used to provide any sort of medical diagonsis. It just records the data but makes no conclusions based on it.

Add this line to your crontab file to run the script every six hours everyday: `0 */6 * * * bash /path/to/can-you-hear-me.sh >/dev/null 2>&1`
## How it works

The app records your output audio for 5 seconds everyday (if you put it in your crontab), and uses ffmpeg to find the average decibel output. It then logs the output to a file, and doesn't rely on system volume indicators, since the source file could be louder/quieter. The recorded file is then destroyed immediately afterwards.

## Requirements
- ffmpeg

- timeout

- lame

- parec and pacmd

- an audio output device
