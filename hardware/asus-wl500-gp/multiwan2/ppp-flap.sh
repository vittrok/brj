#!/bin/sh

[ -z "$1" ] && echo "Error: should be called from ppp-ip-down" && exit 1

LOG="/usr/bin/logger -t ppp-flap-$1"

online_flag=/tmp/$1.online

sleep 30

if [ ! -f $online_flag ] && [ -z "`nvram get $1_testip_1`" ]; then
	$LOG "ppp link down - chanage route" 
	kill -10 `pidof routed.sh`
fi

exit 0
