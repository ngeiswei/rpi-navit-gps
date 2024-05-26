#!/bin/bash
PREV_DIR=$(pwd)
cd ~/Navit
minicom -S start-gps.minicom | grep '\$' | sed 's/^[^$]\+//g' > gps0 &
sleep 5
cd navit-build/navit
./navit
killall -9 minicom
cd "$PREV_DIR"
