#!/bin/bash

ffmpeg -framerate 12 -pattern_type glob -i "./merged/*.png" -c:v libx264 -r 30 -pix_fmt yuv420p -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" "./movies/merged.mp4"
