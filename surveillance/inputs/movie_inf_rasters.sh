#!/bin/bash

# Example command:
# ./movie_inf_rasters.sh ./inf_rasters/cc_NGA_year_0/

topDir=$1

outDir=$topDir"/movies/"

mkdir $outDir

outPath=$outDir'inf_rasters.mp4'

inPath=$topDir'/plots/*.png'

echo $inPath
echo $outPath

ffmpeg -framerate 15 -pattern_type glob -i "$inPath" "$outPath"
