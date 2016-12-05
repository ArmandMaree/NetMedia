#!/bin/bash
echo "SCRIPT START"
export DISPLAY=:0
echo "vlc --fullscreen --play-and-exit $1"
vlc --fullscreen --play-and-exit $1
echo "SCRIPT DONE"

