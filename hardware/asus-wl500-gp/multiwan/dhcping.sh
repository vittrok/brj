#!/bin/sh

[ -z "$1" ] && echo "Error: interface name must be set in arg" && exit 1

sleep 60
kill -SIGUSR1 `cat /tmp/udhcpc.$1.pid | grep .`

exit 0
