#!/bin/bash

ffmpeg -framerate 8 -pattern_type glob -i './plots/*.png' "./movies/output_medium.mp4"
