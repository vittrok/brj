#!/bin/sh

[ -z "$1" ] && echo "Error: should be called from ppp-ip-up or cl-<proto>.sh" && exit 1

LOG="/usr/bin/logger -t route-$1"

route_sem=/tmp/*.route.$1
online_flag=/tmp/$1.online
additional_route=/usr/local/routes/route.$1

if [ ! -f $online_flag ]; then
	if [ -z "`nvram get $1_testip_1`" ] || [ -z "`ip route list match 0.0.0.0`" ]; then
		$LOG "mandatory set 'online' status!" 
		touch $online_flag && kill -10 `pidof routed.sh`
	fi
else
	if [ -n "`ls $route_sem 2>/dev/null`" ]; then
		$LOG "renew all route to $1"
		rm -f $route_sem && kill -10 `pidof routed.sh`
	fi
fi

[ -x $additional_route ] && $additional_route 

exit 0
