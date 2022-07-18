#!/bin/bash

ffmpeg -framerate 3 -pattern_type glob -i './plots/inf_rasters/*.png' "./movies/inf_rasters.mp4"
