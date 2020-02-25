# nodemcu-weightselector
A (very) simple (yet somehow overcomplicated) button to select who stepped on a scale

# Submodules beware

This repo has submodules, notably [nodemcu-scaffold](https://github.com/skrewz/nodemcu-scaffold), and chained therefrom, [nodemcu-libs](https://github.com/skrewz/nodemcu-libs).

You should thus clone with git's `--recursive` flag.

# Prerequisite: Building and flashing nodemcu-firmware

This example uses the [Lua Flash Store](https://nodemcu.readthedocs.io/en/master/lfs/). To facilitate this, you'll a [build](http://nodemcu-build.com/) an image with roughly these modules:

```
adc,bme280,bme680,file,gpio,i2c,mdns,mqtt,net,node,pwm,rtctime,sntp,spi,tmr,uart,wifi,tls
```

And with a non-zero LFS size. I found 64KiB is sufficient, as these LFS images wind up around 30KiB in size.

Flash said firmware using e.g. [esptool.py](https://github.com/themadinventor/esptool):

```
$ ./esptool.py --port /dev/ttyUSB0 write_flash -fm qio 0x00000  nodemcu-master-*-modules-*.bin
esptool.py v2.2
Connecting....
Detecting chip type... ESP8266
Chip is ESP8266EX
Uploading stub...
Running stub...
Stub running...
Configuring flash size...
Auto-detected Flash size: 4MB
Flash params set to 0x0040
Compressed 475136 bytes to 309820...
Wrote 475136 bytes (309820 compressed) at 0x00000000 in 27.3 seconds (effective 139.2 kbit/s)...
Hash of data verified.

Leaving...
Hard resetting...
```

# Uploading

Two step process thus far. To upload a file named `lfs.img` to SPIFFS as well as `init.lua`:

```sh
make upload
```

At this point, you'll need to `make console` onto the device and run `node.flashreload("lfs.img")` from there. It should print `LFS region updated.  Restarting.` in response (and then reboot). At this point, the firmware is operational and will attempt to connect to my MQTT broker.

## Configuring tidbits

You may want to configure wifi by `make console`'ing into the device and putting in your credentials:

```lua
wifi.setmode(wifi.STATION)
wifi.sta.config {ssid="mySsid",pwd="supersecret"}
```

Obviously, you'd need to change the scaffold setup to use your preferred values. Put in a feature request if you'd like me to generalise the setup as it stands.


# Usage

This is pretty specific to my use case. Two people (`user1` and `user2`) have each their side of a flipbutton, and an independent system publishes a raw float value onto `datainput/bathroom/scale/raw`.

This software's only goal in life is to interpret this relative to the state of the button, and re-publish accordingly. That's a fair bit of work for something so trivial.
