# Raspberry Pi Navit GPS

## Overview

Description of my personal attempt to build a Raspberry Pi Navit GPS.

## Requirements

### Hardware

- Raspberry Pi 3 Model B Rev 1.2
- 5" DSI LCD Touch Screen Display Kit

### Software

- [rpi-imager](https://www.raspberrypi.com/software/)
- [Navit](https://www.navit-project.org/)
- [Evemu](https://www.freedesktop.org/wiki/Evemu/)

## Build

### Install Raspbian

Install Raspbian on a MicroSD card via
[rpi-imager](https://www.raspberrypi.com/software/ for instructions).
Make sure the card has enough memory to support the map of your region
(as a point of reference, a map of Europe may require up to 30GB).
Make sure the MicroSD card is compatible with you Rapsberry Pi, see
[RPi_SD_cards](https://elinux.org/RPi_SD_cards) for more information.

### Install Display

Mount the 5" DSI LCD Touch Screen Display Kit onto the Raspberry Pi
and connect the touch screen via the Display Port.

### Boot-up Raspberry Pi

1. Connect a mouse and keyboard to your Raspberry Pi.
2. Power it via micro USB.
3. Complete the installation.
4. Open a terminal to install the rest of the needed software.

### Install Navit

As of March 2024, the deb package of Navit provided by default,
`navit/oldstable 0.5.5+dfsg.1-2 armhf`, is not operational enough, we
must therefore compile it from source.

#### Install Prerequisites

TODO

#### Build Navit

TODO

### Install Evemu

Evemu is used to recognize touchscreen gestures to zoom in and out.
To install simply type

```bash
sudo apt install evemu-tools
```

## Usage
