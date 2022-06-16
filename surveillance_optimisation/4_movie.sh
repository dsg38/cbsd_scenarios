#!/bin/bash

ffmpeg -framerate 15 -pattern_type glob -i './plots/*.png' "./movies/output.mp4"
