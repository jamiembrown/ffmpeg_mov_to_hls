# ffmpeg_mov_to_hls
The goal of this repo is to document how I convert mov files that I've downloaded from Shutterstock into variable bitrate HLS packages that can be used as the background video on a web page.

You will need ffmepg installed - if you're a homebrew user on Mac then first do this:

`brew install ffmpeg`

Then to run the script execute:

`./convertvideo.sh yourvideo.mov`

It will first convert your video to mp4, removing the audio stream, and then to an HLS package with three different sizes and bitrates.

I am not an expert on video or ffmpeg, so I'd love feedback or pull requests - but this process seems to be woefully badly documented online, so wanted to make a start.