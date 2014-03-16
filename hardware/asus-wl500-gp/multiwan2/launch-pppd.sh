#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set in arg" && exit 1

while true; do

	/usr/sbin/pppd file /tmp/ppp/ppp.conf.$1
	
	sleep 2

done

exit 0
