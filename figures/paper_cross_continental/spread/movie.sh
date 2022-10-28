#!/bin/bash

job=$1

mkdir "./movies/$job"

ffmpeg -framerate 3 -pattern_type glob -i "./plots/$job/*.png" -c:v libx264 -r 30 -pix_fmt yuv420p -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" "./movies/$job/output_medium.mp4"
