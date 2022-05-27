#!/bin/bash

ffmpeg -framerate 0.8 -pattern_type glob -i '*.png' output_medium.mp4
