#!/bin/bash

ffmpeg -framerate 30 -pattern_type glob -i './plots/maps/*.png' "./movies/output.mp4"
