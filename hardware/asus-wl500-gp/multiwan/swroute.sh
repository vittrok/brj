#!/bin/sh

dgw_sem=/tmp/def.route
vgw_sem=/tmp/vpn.route

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

	while route delete default > /dev/null 2>&1 ; do : ; done
	route add default gw $gw

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

unsetdefgw()
{
	$LOG "ALL wan pors fail! unset default gateway"
	
	while route delete default > /dev/null 2>&1 ; do : ; done
	
	$LOG "done delete route"
	
	rm ${dgw_sem}.* > /dev/null 2>&1
	touch ${dgw_sem}.none
	
	return 0
}

setvpngw()
{
	[ -z "$1" ] && $LOG "Error: wan interface name must be set!" && return 1

	if [ "$1" = "def" ]; then
		$LOG "switch vpn route to default gateway"
		$LOG "delete vpn route from routing table"
		
		for vpn_host in `nvram get vpn_hosts` ; do
			while ip route del $vpn_host > /dev/null 2>&1 ; do : ; done
		done
		
		rm ${vgw_sem}.* > /dev/null 2>&1
		$LOG "done delete vpn route"
	else
		gw=`nvram get $1_gateway_t`
		
		[ -z "$gw" ] && $LOG "ERROR! gateway for $1 not set in nvram!" && return 1
		
		$LOG "set vpn route to $1"
		$LOG "add vpn route to routing table"
		
		for vpn_host in `nvram get vpn_hosts` ; do
			ip route replace $vpn_host via $gw
		done
		
		rm ${vgw_sem}.* > /dev/null 2>&1
		touch ${vgw_sem}.$1
		
		$LOG "done add vpn route"
	fi
	
	return 0
}


# default route

if   [ -f $wan1_sem ]; then [ ! -f ${dgw_sem}.wan1 ] && setdefgw wan1
elif [ -f $wan2_sem ]; then [ ! -f ${dgw_sem}.wan2 ] && setdefgw wan2
elif [ -f $wan3_sem ]; then [ ! -f ${dgw_sem}.wan3 ] && setdefgw wan3
else rm ${dgw_sem}.* > /dev/null 2>&1
fi

# vpn route

if [ ! -z "`nvram get vpn_hosts`" ]; then
	[ -f ${vgw_sem}.wan2 ] && [ ! -f $wan2_sem ] && setvpngw def
	[ ! -f ${vgw_sem}.wan2 ] && [ -f $wan2_sem ] && setvpngw wan2
fi

$LOG "switch rouing process finish"

exit 0
