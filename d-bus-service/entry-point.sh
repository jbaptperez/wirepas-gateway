#!/bin/sh

if [ $# -eq 0 ] || [ "$1" = 'start' ]; then

    if [ -f '/var/run/dbus/pid' ]; then
        rm -f '/var/run/dbus/pid'
    fi

    exec /usr/bin/dbus-daemon --system --nofork --print-address
else
    exec $@
fi
