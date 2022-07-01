#!/bin/bash

ffmpeg -framerate 12 -pattern_type glob -i './merged/*.png' "./movies/merged.mp4"
