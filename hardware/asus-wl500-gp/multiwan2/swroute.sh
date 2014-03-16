#!/bin/sh

dgw_sem=/tmp/def.route
sip_sem=/tmp/sip.route

wan1_sem=/tmp/wan1.online
wan2_sem=/tmp/wan2.online
wan3_sem=/tmp/wan3.online

LOG="/usr/bin/logger -t switchroute"

$LOG "switch rouing process start"

setdefgw()
{
	[ -z "$1" ] && $LOG "Error: wan interface name must be set!" && return 1

	gw=`nvram get $1_gateway_t`

	[ -z "$gw" ] && $LOG "ERROR! gateway for $1 not set in nvram!" && return 1

	$LOG "switch default route to $1"
	$LOG "change default route to $gw"

	ip route flush exact 0/0
	ip route replace default via $gw
	ip route flush cache

	$LOG "done change route"
	
	if [ -z `nvram get master_dns_1` ]; then 
	
		$LOG "change /etc/resolv.conf"
		cp /tmp/resolv.conf.$1 /tmp/resolv.conf > /dev/null 2>&1
		kill -HUP `pidof dnsmasq`
	fi
	
	rm ${dgw_sem}.* > /dev/null 2>&1
	touch ${dgw_sem}.$1
	
	return 0
}

# default route

if   [ -f $wan1_sem ]; then [ ! -f ${dgw_sem}.wan1 ] && setdefgw wan1
elif [ -f $wan2_sem ]; then [ ! -f ${dgw_sem}.wan2 ] && setdefgw wan2
#elif [ -f $wan3_sem ]; then [ ! -f ${dgw_sem}.wan3 ] && setdefgw wan3
else rm ${dgw_sem}.* > /dev/null 2>&1
fi

$LOG "switch rouing process finish"

exit 0
