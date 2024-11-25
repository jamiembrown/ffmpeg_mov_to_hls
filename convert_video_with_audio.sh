#!/bin/bash

# Check if a filename is provided
if [ -z "$1" ]; then
  echo "Usage: $0 input.mov"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_DIR="${INPUT_FILE%.*}_hls"
MP4_FILE="${INPUT_FILE%.*}_temp.mp4"

# Encode the input video and audio into an intermediate MP4 file
ffmpeg -i "$INPUT_FILE" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -c:a aac -b:a 128k "$MP4_FILE"

# Create output directory
mkdir -p $OUTPUT_DIR

# Run ffmpeg to convert to HLS with variable bitrates
ffmpeg -i "$MP4_FILE" \
    -filter_complex "[0:v]split=3[v1][v2][v3]; \
    [v1]scale=1920:1080[v1out]; \
    [v2]scale=1280:720[v2out]; \
    [v3]scale=854:480[v3out]" \
    -map "[v1out]" -map a:0 -c:v:0 libx264 -b:v:0 5000k -maxrate:v:0 5500k -bufsize:v:0 7500k -preset veryfast -g 48 -keyint_min 24 -sc_threshold 0 -pix_fmt yuv420p -c:a:0 aac -b:a:0 128k \
    -map "[v2out]" -map a:0 -c:v:1 libx264 -b:v:1 2500k -maxrate:v:1 3000k -bufsize:v:1 4500k -preset veryfast -g 48 -keyint_min 24 -sc_threshold 0 -pix_fmt yuv420p -c:a:1 aac -b:a:1 128k \
    -map "[v3out]" -map a:0 -c:v:2 libx264 -b:v:2 1000k -maxrate:v:2 1500k -bufsize:v:2 2000k -preset veryfast -g 48 -keyint_min 24 -sc_threshold 0 -pix_fmt yuv420p -c:a:2 aac -b:a:2 128k \
    -f hls -hls_time 6 -hls_playlist_type vod \
    -hls_segment_filename "$OUTPUT_DIR/output_%v/segment_%03d.ts" \
    -master_pl_name "master.m3u8" \
    -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" \
    -hls_flags independent_segments \
    "$OUTPUT_DIR/output_%v/prog.m3u8"

echo "HLS conversion complete. Output saved in $OUTPUT_DIR"