#!/bin/bash

ffmpeg -framerate 50 -pattern_type glob -i './plots/maps/*.png' "./movies/output.mp4"
