#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set in arg" && exit 1

LOG="/usr/bin/logger -t pinger-$1"

live_c=0
dead_c=0
flip_trsh=3    
dead_trsh=3       
live_trsh=8

host1=`nvram get $1_testip_1`
host2=`nvram get $1_testip_2`

[ -z "$host1" ] || [ -z "$host2" ] && ($LOG "Error: set test ip addresses for $1 in nvram" ; exit 1)

online_flag=/tmp/$1.online
proto=`nvram get $1_protocol`

$LOG "pinger process start for interface $1"

[ -f $online_flag ] && $LOG "$1 is online now" || $LOG "$1 is offline now"

while true; do 

    if ping -c 1 $host1 > /dev/null 2>&1 || ping -c 1 $host2 > /dev/null 2>&1 ; then
	let live_c+=1
        [ $live_c -ge $flip_trsh ] && dead_c=0
    else
        let dead_c+=1
        live_c=0
    fi
    
    if [ ! -f $online_flag ] && [ $live_c -ge $live_trsh ]; then 
        touch $online_flag
        $LOG "### $1 is ALIVE! ### count: $live_c ###"
       	kill -10 `pidof routed.sh`
    fi

    if [ -f $online_flag ] && [ $dead_c -ge $dead_trsh ]; then
        rm $online_flag
        $LOG "### $1 is DEAD! ### count: $dead_c ###"
        [ "$proto" = "dhcp" ] && /usr/local/sbin/dhcping.sh $1 &
        kill -10 `pidof routed.sh`
    fi
    
    sleep 10

done

exit 0
