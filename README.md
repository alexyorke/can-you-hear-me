# can-you-hear-me
An app to predict and prevent hearing loss by measuring the output volume everyday. Over time, you can see how much the output volume level has increased (if at all.)

It cannot be used to provide any sort of medical diagonsis. It just records the data but makes no conclusions based on it.

Add this line to your crontab file to run the script every six hours everyday: `0 */6 * * * bash /path/to/can-you-hear-me.sh >/dev/null 2>&1`
## How it works

The app records your output audio for X seconds everyday (if you put it in your crontab), and uses ffmpeg to find the average decibel output. It then uses ffmpeg to find the average volume of the recording. No temporary files are saved to disk.

It does not rely on the volume indicator, or any other app-defined volume sliders (like YouTube). Instead, it takes the volume of the raw output after all of the processing the OS does just before you listen to it to ensure accuracy.

## Roadmap

- make choosing an audio output device easier

- record later if the user isn't playing any audio

- create a histogram of dB levels, so that the highest points can be plotted (since exposure to a loud noise for a short period of time can be detremental)

## Requirements
- ffmpeg

- timeout

- lame

- parec and pacmd

- an audio output device
