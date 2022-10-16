lwrf.cmd
========

LightwaveRF Windows Command Line Control v7.2 by Jamie Burchell

## Usage:

```
lwrf link
lwrf room-name device-name on|off|open|close|stop|lock|full-lock|unlock|dim 1-100|colour [colour-name|cycle]
lwrf room-name off
lwrf room-name mood mood-name
lwrf trv trv-name link|unlink|on|off|temp 0-40|pos 0-5
lwrf stat stat-name link|unlink|temp 0-40|mode [standby|running|away|frost|constant|holiday 1-90]
lwrf seq sequence-name
lwrf seq cancel-all
```

## Examples:

```
lwrf lounge lights dim 50
lwrf lounge lights colour red
lwrf lounge mood relax
lwrf "sitting room" "wall lights" on
lwrf seq "my sequence"
lwrf trv lounge temp 22
lwrf stat sitting-room temp 22
lwrf stat sitting-room mode constant
lwrf stat sitting-room mode holiday 14
```

## Requirements:

1. The ncat utility to send the messages. Download the Windows binary from http://nmap.org/ncat and put it in the Windows PATH (e.g. system32 folder)
2. You must edit the configuration parameters at the top of the lwrf.cmd script
3. Allow ports %wifi_link_port% outbound (UDP) and %source_port% inbound (UDP) on the device
4. The MAC address of this device must be registered with your WifiLink.
   Enter: `lwrf link` and select "Yes" at the WifiLink unit

## Forum/Support
http://lightwaverfcommunity.org.uk/forums/topic/windows-command-line-control
