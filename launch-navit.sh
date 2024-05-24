#!/bin/bash
PREV_DIR=$(pwd)
cd ~/Navit/rpi-navit-gps
minicom -S start-gps.minicom > ~/Navit/gps0 &
cd ~/Navit/navit-build/navit
./navit
killall minicom
cd "$PREV_DIR"
