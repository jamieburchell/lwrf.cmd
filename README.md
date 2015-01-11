lwrf.cmd
========

LightwaveRF Windows Command Line Control v5 by Jamie Burchell

## Usage:

```
lwrf reg
lwrf room-name device-name on|off|lock|unlock|dim 1-100
lwrf room-name off
lwrf room-name mood mood-name
lwrf seq sequence-name
lwrf seq --cancel-all
```

## Examples:

```
lwrf lounge lights dim 50
lwrf lounge mood relax
lwrf "sitting room" "wall lights" on
lwrf seq "my sequence"
```

## Requirements:

1. The ncat utility to send the messages. Download the Windows binary from http://nmap.org/ncat and put it in the Windows PATH (e.g. system32 folder)
2. You must edit the configuration parameters at the top of the lwrf.cmd script
3. Allow ports %wifi_link_port% outbound (UDP) and %source_port% inbound (UDP) on the device
4. The MAC address of this device must be registered with your WifiLink.
   Enter: lwrf reg and select "Yes" at the WifiLink unit
