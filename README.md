# Raspberry Pi Navit GPS

## Overview

Description of my personal attempt to build a Raspberry Pi Navit GPS.

## Requirements

### Hardware

- Raspberry Pi 3 Model B Rev 1.2
- 5" DSI LCD Touch Screen Display Kit.

### Software

- [rpi-imager](https://www.raspberrypi.com/software/)
- [Navit](https://www.navit-project.org/)

## Assemble Hardware

### Install Raspbian

Before assembling the Raspberry Pi GPS, install Raspbian on a microSD
card via [rpi-imager](https://www.raspberrypi.com/software/ for
instructions).  Make sure the card has enough memory to support the
map of your region (as a point of reference, a map of Europe may
require up to 30GB).  Make sure the microSD card is compatible with
you Rapsberry Pi, see [RPi_SD_cards](https://elinux.org/RPi_SD_cards)
for more information.

Insert the microSD card into its slot.

### Install Display

Mount the 5" DSI LCD Touch Screen Display Kit onto the Raspberry Pi
and connect the touch screen via the Display Port.

## Assemble Software

### Boot-up Raspberry Pi

1. Connect a mouse and keyboard to your Raspberry Pi.
2. Power it via micro USB.
3. Complete the installation.  For the rest of the document, we will
   assume that the user name is `gps`.
4. Open a terminal to install the rest of the needed software.

### Install Navit

Debian packages of Navit are sometimes deficient, I recommend you
compile it from source.

#### Install Prerequisites

From the terminal, install the following packages.

1. Building tools

```
sudo apt install git cmake g++ gettext protobuf-c-compiler
```

2. GPS software

```
sudo apt install gpsd gpsd-clients
```

3. Additional libraries

```
sudo apt install libpng-dev libgtk2.0-dev librsvg2-bin \
                 libgps-dev libdbus-glib-1-dev freeglut3-dev \
                 libfreeimage-dev libprotobuf-c-dev zlib1g-dev \
```

#### Build Navit

Do not use the latest revision from the git repository, it might be
broken.  Instead, fetch the latest release, 0.5.6 as of April 2024

```
wget https://github.com/navit-gps/navit/archive/refs/tags/v0.5.6.tar.gz
```

Unpack

```
tar xvf v0.5.6.tar.gz
```

It should create a `navit-0.5.6` folder, do not enter that folder,
rather create a `navit-build` folder next to it

```
mkdir navit-build
```

Enter this folder

```
cd navit-build
```

and compile

```
cmake ~/navit-0.5.6
make
```

#### Test Navit

First, let's make sure that Navit works.  Go to the folder containing
the Navit excecutable

```
cd navit
```

Then run Navit

```
./navit
```

You should see the map of Munich.  Press anywhere on the map and then
press on the quite button.

#### Supply a map

Depending on the size of the map you want, you may need to perform
that operation on a bigger machine than a Raspberry Pi.  I provide
here the instructions for the map of Europe which is too big to be
compiled on the Raspberry Pi.

Go to your desktop, install `maptool`

```
sudo apt install maptool
```

Download the map of your choice (here Europe)

```
wget -c https://download.geofabrik.de/europe-latest.osm.pbf
```

Compile it

```
maptool --threads=4 --protobuf -i europe-latest.osm.pbf osm_europe.bin
```

this may take a while.  Then copy the bin file to your raspberry pi,
under the folder

```
~/navit-build/navit/maps
```

#### Configure Navit

Now let's configure Navit.  You need to edit `navit.xml` with the
editor of your choice, mine is Emacs

```
sudo apt install emacs
```

Then, still from within the folder you've launched Navit from, open
`navit.xml`

```
emacs navit.xml
```

##### Fullscreen

To have Navit start in fullscreen, search the line

```
		<gui type="internal" enabled="yes"><![CDATA[
```

and replace it by

```
		<gui type="internal" enabled="yes" fullscreen="1"><![CDATA[
```

##### Point to the supplied map

Search the string `binfile`, you should be to a line like

```
		<!-- Mapset template for OpenStreetMap -->
		<mapset enabled="no">
			<map type="binfile" enabled="yes" data="/media/mmc2/MapsNavit/osm_europe.bin"/>
		</mapset>
```

Replace `enabled="no"` by `enabled="yes"` and
`data="/media/mmc2/MapsNavit/osm_europe.bin"` by
`data="/home/gps/navit-build/maps/osm_europe.bin"`.

You may want to disable any other mapset templates, so search for
`mapset enabled="yes"` and replaced it by `mapset enabled="no"` if it
is not an OpenStreetMap template.

##### Add zoom in/out buttons

Search the lines

```
		<osd enabled="no" type="button" x="-96" y="-96" command="zoom_in()" src="zoom_in.png"/>
		<osd enabled="no" type="button" x="0" y="-96" command="zoom_out()" src="zoom_out.png"/>
```

and replace `enabled="no"` by `enabled="yes"` in both lines.  Feel
free to reposition the buttons to your liking.  The `x` and `y`
coordinates are in pixel.  The top left corner corresponds to `x=0`
and `y=0`.  Incrementing `x` moves the button right while incrementing
`y` moves it down.  If negative values are used then it is as if the
origin was the bottom right corner and `x` and `y` move in the
opposite directions.

### Configure the Raspberry Pi

In order to have navit launched at start-up

## Usage

## Acknowledgement

This document has been greatly facilitated by

https://ozzmaker.com/navigating-navit-raspberry-pi/
