ffmpeg -framerate 0.8 -pattern_type glob -i '*.png' output.mp4

# https://video.stackexchange.com/questions/10825/how-to-hold-the-last-frame-when-using-ffmpeg
# TODO: Doesn't work
ffmpeg -framerate 0.8 -pattern_type glob -i '*.png' -vf tpad=stop_mode=clone:stop_duration=3 output.mp4

