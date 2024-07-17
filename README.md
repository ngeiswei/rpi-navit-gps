# Raspberry Pi Navit GPS

## Overview

Description of my personal attempt to build a Raspberry Pi Navit GPS.

## Requirements

### Hardware

- Raspberry Pi 3 Model B Rev 1.2
- 5" DSI LCD Touch Screen Display Kit.
- SIM7600X 4G HAT

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

### Install SIM7600X 4G HAT

Connect the SIM7600X to the Raspberry Pi via the GPIO interface.  To
my experience, if all you use is the GPS then you do not need to plug
the USB cable.

In order to hold the SIM7600X firmly you can use motherboard standoffs
between the Raspberry Pi and the SIM7600X. (TODO: determine precise
size, ~15mm).

## Assemble Software

### Boot-up Raspberry Pi

1. Connect a mouse and keyboard to your Raspberry Pi.
2. Power it via micro USB.
3. Complete the installation.  For the rest of the document, we will
   assume that the user name is `gps`.
4. Open a terminal to install the rest of the needed software.

### Install Building Tools

```bash
sudo apt install git cmake g++ gettext protobuf-c-compiler
```

### Create Navit Folder

Let us create a folder where we will place all the tools, including
navit itself

```
mkdir ~/Navit
```

Enter that folder

```
cd ~/Navit
```

### Clone this Repository

Clone this repository into our Raspberry Pi

```bash
git clone https://github.com/ngeiswei/rpi-navit-gps.git
```

### Configure SIM7600X 4G HAT

First, enable the serial port.  Launch the Raspberry Pi configuration
tool

```bash
sudo raspi-config
```

Select `Interface Option`, then `Serial Port`.  To the question

```
Would you like a login shell to be accessible over serial?
```

answer `No`.

Then, to the question

```
Would you like the serial port hardware to be enabled?
```

answer `Yes`.

Then select `Ok` and reboot.

### Install Minicom

To access the GPS sensor we must install `minicom`

```bash
sudo apt install minicom
```

### Test the SIM7600X 4G HAT

Launch minicom

```bash
minicom -D /dev/ttyS0
```

Inside minicom, enter the following command to active the GPS

```
AT+CGPS=1,1
```

which should output

```
OK
```

Check that the GPS is activated which the command

```
AT+CGPS?
```

which should return

```
+CGPS: 1,1

OK
```

Then, enter

```
AT+CGPSINFO
```

which should output

```
,,,,,,
```

Wait for 5 minutes, which should be enough time for your device to get
localized, and enter again

```
AT+CGPSINFO
```

which should now output GPS coordonates

```
+CGPSINFO: 1234.123456,N,1245.123456,E,123456,123456.1,12.1,1,1,123,1
```

Deactivate the GPS

```
AT+CGPS=0
```

which should output

```
OK
AT+CGPS=0
```

Exit minicom with Ctrl-A, then Z, and then X.

### Configure the SIM7600X 4G HAT

#### Automatically Activate the GPS

Launch minicom once again

```bash
minicom -D /dev/ttyS0
```

type the commands

```
AT+CGPSAUTO=1
AT+CGPSINFOCFG=1,31
```

The latter instructs the GPS to output coordinates in NMEA format
every second, which you see on your terminal screen.

Now, without exiting minicom, open another terminal and type

```bash
cat /dev/ttyS0
```

which should also output a stream of GPS coordinates.

You can exist minicom and see that the stream of GPS coordinates stops
being output from `cat /dev/ttyS0`.  If you still see a stream of data
coming out of `cat /dev/ttyS0`, but no GPS coordinates, it is normal.

#### Configure minicom

Let us configure minicom to use `/dev/ttyS0` by default, enter

```bash
sudo minicom -s
```

Select the `Serial port setup` option.  Type `A` and set the field
`A - Serial device` to `/dev/ttyS0`.  Press enter twice to go back to
the menu and select `Save setup as dfl`.  You can now exit by
selecting `Exit from Minicom`.

You may launch minicom once again

```bash
minicom
```

and see that it outputs a stream of GPS coordinates (unless you have
restarted the Raspberry Pi since you entered `AT+CGPSINFOCFG=1,31`).

### Install Navit

The debian packages of Navit is sometime insufficient, I recommend you
compile it from source.

#### Install Prerequisites

From the terminal, install the following packages.

```bash
sudo apt install libpng-dev libgtk2.0-dev librsvg2-bin \
                 libgps-dev libdbus-glib-1-dev freeglut3-dev \
                 libfreeimage-dev libprotobuf-c-dev zlib1g-dev \
```

Install speech synthesizers

```bash
sudo apt install espeak festival festvox-us-slt-hts
```

(Note to self: maybe `gpsd` and `gpsd-clients` need to be installed).

#### Build Navit

Do not use the latest revision from the git repository, it might be
broken.  Instead, from the `~/Navit` folder, fetch the latest release,
0.5.6 as of April 2024

```bash
wget https://github.com/navit-gps/navit/archive/refs/tags/v0.5.6.tar.gz
```

Unpack

```bash
tar xvf v0.5.6.tar.gz
```

It should create a `navit-0.5.6` folder, do not enter that folder,
rather create a `navit-build` folder next to it

```bash
mkdir navit-build
```

Enter that folder

```bash
cd navit-build
```

and compile

```bash
cmake ../navit-0.5.6
make -j
```

#### Test Navit

First, let's make sure that Navit works.  Go to the folder containing
the Navit excecutable

```bash
cd navit
```

Then run Navit

```bash
./navit
```

You should see the map of Munich.  Press anywhere on the map and then
press on the quite button.

#### Create GPS FIFO

Create a FIFO to receive GPS data

```bash
mkfifo ~/Navit/gps0
```

#### Supply a map

Depending on the size of the map you may need to perform that
operation on a bigger machine than a Raspberry Pi.  I provide here the
instructions for the map of Europe which is too big to be compiled on
the Raspberry Pi.

Go to your desktop, install `maptool`

```bash
sudo apt install maptool
```

Download the map of your choice (here Europe)

```bash
wget -c https://download.geofabrik.de/europe-latest.osm.pbf
```

Compile it

```bash
maptool --threads=4 --protobuf -i europe-latest.osm.pbf osm_europe.bin
```

this may take a while.  Then copy the bin file to your raspberry pi,
under the folder

```bash
~/Navit/navit-build/navit/maps
```

#### Configure Navit

Now let's configure Navit.  You need to edit `navit.xml` with the
editor of your choice, mine is Emacs

```bash
sudo apt install emacs
```

Then, still from within `~/Navit/navit-build/navit`, open `navit.xml`

```bash
emacs navit.xml
```

##### Fullscreen

To have Navit start in fullscreen, look for

```xml
		<gui type="internal" enabled="yes"><![CDATA[
```

and replace it by

```xml
		<gui type="internal" enabled="yes" fullscreen="1"><![CDATA[
```

##### Point to the supplied map

Look for the string `binfile`, it should be inside a line like

```xml
		<!-- Mapset template for OpenStreetMap -->
		<mapset enabled="no">
			<map type="binfile" enabled="yes" data="/media/mmc2/MapsNavit/osm_europe.bin"/>
		</mapset>
```

Replace `enabled="no"` by `enabled="yes"` and
`data="/media/mmc2/MapsNavit/osm_europe.bin"` by
`data="/home/gps/Navit/navit-build/navit/maps/osm_europe.bin"`.

You may want to disable any other mapset templates, so search for
`mapset enabled="yes"` and replaced it by `mapset enabled="no"` if it
is not an OpenStreetMap template.

##### Add zoom in/out buttons

Look for the lines

```xml
		<osd enabled="no" type="button" x="-96" y="-96" command="zoom_in()" src="zoom_in.png"/>
		<osd enabled="no" type="button" x="0" y="-96" command="zoom_out()" src="zoom_out.png"/>
```

and replace them by

```xml
		<osd enabled="yes" type="button" x="-96" y="96" command="zoom_in()" src="zoom_in.png"/>
		<osd enabled="yes" type="button" x="-96" y="192" command="zoom_out()" src="zoom_out.png"/>
```

Feel free to reposition the buttons to your liking.  The `x` and `y`
coordinates are in pixel.  The top left corner corresponds to `x=0`
and `y=0`.  Incrementing `x` moves the button right while incrementing
`y` moves it down.  If negative values are used then it is as if the
origin was the bottom right corner and `x` and `y` move in the
opposite directions.

##### Point to the GPS

Look for

```xml
		<vehicle name="Local GPS" profilename="car" enabled="yes" active="1" source="gpsd://localhost" gpsd_query="w+xj">
```

and replace it by

```xml
		<vehicle name="Local GPS" profilename="car" enabled="yes" active="1" source="file://home/gps/Navit/gps0" follow="5">
```

##### Enable Speech

Look for

```xml
		<speech type="cmdline" data="echo 'Fix the speech tag in navit.xml to let navit say:' '%s'" cps="15"/>
```

For a male robotic voice, replace it by

```xml
		<speech type="cmdline" data="espeak '%s'" cps="15"/>
```

For a female natural voice, replace it by

```xml
		<speech type="cmdline" data="festival -b '(voice_cmu_us_slt_arctic_hts)' '(SayText '%s')'" cps="15"/>
```

##### Add Layers

Look for

```xml
		<osd enabled="no" type="navigation_next_turn"/>
```

replace by

```xml
		<osd enabled="yes" type="navigation_next_turn"/>
```

Then, under that line add the following lines

```xml
		<!-- Distance to Next Maneouvre -->
		<osd enabled="yes" type="text" label="${navigation.item[1].length[named]}" x="0" y="0" font_size="350" w="75" h="30" align="0" background_color="#000000c8" osd_configuration="2" />
		<!-- Next Road -->
		<osd enabled="yes" type="text" label="   ${navigation.item[1].street_name} ${navigation.item[1].street_name_systematic}" x="75" y="0" font_size="450" w="824" h="40" align="4" background_color="#000000c8" osd_configuration="2" />
		<!-- Route Distance -->
		<osd enabled="yes" type="text" label="DTG ${navigation.item.destination_length[named]}" w="125" h="20"  x="-125" y="0"  font_size="300" align="8" background_color="#000000c8" osd_configuration="2" />
		<!-- Arrival Time -->
		<osd enabled="yes" type="text" label="ETA ${navigation.item.destination_time[arrival]}" x="-125" y="20"  font_size="300" w="125" h="20" align="8" background_color="#000000c8" osd_configuration="2" />
		<!-- Current Altitude -->
		<osd enabled="yes" type="text" label="${vehicle.position_height}" x="0" y="-20"  font_size="300" w="60" h="20" align="4" background_color="#000000c8"/>
		<!-- Current Direction -->
		<osd enabled="yes" type="text" label="ALT" x="0" y="-40"  font_size="200" w="60" h="20" align="4" background_color="#000000c8"/>
		<!-- Current Street -->
		<osd enabled="yes" type="text" label="${tracking.item.street_name} ${tracking.item.street_name_systematic}" x="60" y="-40"  font_size="500" w="764" h="40" align="4" background_color="#000000c8"/>
		<!-- Speed Warner -->
		<osd enabled="yes" type="speed_warner" w="100" h="40" x="-300" y="-40" font_size="500" speed_exceed_limit_offset="15" speed_exceed_limit_percent="10" announce_on="1" background_color="#00000000" label="text_only" align="8"/>
		<!-- Current Speed -->
		<osd enabled="yes" type="text" label="${vehicle.position_speed}" x="-200" y="-40" font_size="500" w="150" h="40" align="0" background_color="#000000c8"/>
		<!-- GPS Status -->
		<osd enabled="yes" type="gps_status" x="-50" y="-40" w="50" h="40" background_color="#000000c8"/>
```

##### Remove Nigh Mode

If you do not wish to use night mode, you can disable it by removing

```
nightlayout="Car-dark"
```

from `navit_layout_car.xml` (same folder as `navit.xml`).

### Configure the Raspberry Pi

We provide a script, `launch-navit.sh`, that launches minicom,
redirects the GPS data to the `gps0` FIFO and launches Navit.  Copy
the following files under `~/Navit`

```
cp ~/Navit/rpi-navit-gps/{launch-navit.sh,start-gps.minicom} ~/Navit
```

To launch that script at start-up TODO.

## Acknowledgement

This document is based on the following resources

https://ozzmaker.com/navigating-navit-raspberry-pi/
https://www.waveshare.com/wiki/SIM7600X_4G_HAT_Guides_for_Pi
https://core-electronics.com.au/guides/raspberry-pi-4g-gps-hat/
https://dev.to/nakullukan/raspberrypi-sim7600-gpsd-2969
