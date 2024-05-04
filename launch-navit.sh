#!/bin/bash
cd ~/rpi-navit-gps
minicom -S start-gps.minicom > ~/navit-build/navit/gps0 &
cd ~/navit-build/navit
./navit
killall minicom
cd ~
