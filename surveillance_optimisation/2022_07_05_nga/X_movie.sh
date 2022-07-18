#!/bin/bash

ffmpeg -framerate 80 -pattern_type glob -i './plots/maps/*.png' "./movies/output_1.mp4"
