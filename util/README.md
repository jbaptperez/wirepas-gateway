# Utilities

## Fixed sink serial paths with dedicated udev rules

The `99-wirepas-sinks.rules` file contains predefined udev rules that add
fixed sink paths within the `/dev` directory.
The following name convention is used:

````
/dev/serial/by-wirepas-sink-id/[x]
````
where [x] is the sink ID.

The `99-wirepas-sinks.rules` contains rules for:
* Raspberry Pi 3B+ (default)
* Raspberry Pi 2B+ (commented)
* Dell Vostro  (commented)

Copy this file into the `/etc/udev/rules.d/` directory of the host, adapt
comments to your configuration and either use the `udevadm trigger` command or
reboot your host system to make the rules applied.
