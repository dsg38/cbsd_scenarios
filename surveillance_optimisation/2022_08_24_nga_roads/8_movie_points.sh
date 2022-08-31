#!/bin/bash

ffmpeg -framerate 30 -pattern_type glob -i './plots/2022_08_26_detectionProp_085/points/*.png' "./movies/points/2022_08_26_detectionProp_085.mp4"
