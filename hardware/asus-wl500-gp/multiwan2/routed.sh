#!/bin/sh

[ "`pidof routed.sh`" != "$$" ] && echo "Error: another copy of routed.sh running!" && exit 1

LOG="/usr/bin/logger -t routed"

$LOG "routed script start"

trap 	"$LOG 'wan intefaces status changed, launch swroute.sh'
	/usr/local/sbin/swroute.sh" 10

while true; do sleep 2 ; done

exit 0
