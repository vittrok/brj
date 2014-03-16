#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

interface=`nvram get $1_ifname`

[ -z "$interface" ] && echo "Error: interface name for $1 not set in nvram!" && exit 1
[ "`nvram get $1_protocol`" != "pppoe" ] && echo "Error: incorrect protocol for $1 set in nvram!" && exit 1

/usr/bin/logger -t pppoe-$1 "start pppoe process for $1"

nvram set $1_ipaddr_t=
nvram set $1_gateway_t=
nvram set $1_pppdev_t=

/usr/local/sbin/conf-ppp.sh $1
/usr/local/sbin/conf-resolv.sh $1

ifconfig $interface up

/usr/sbin/pppd file /tmp/ppp/ppp.conf.$1

case "`nvram get $1_pppoe_type`" in
	dhcp)
		/usr/local/sbin/wan-dhcp.sh $1
		;;
	static)
		/usr/local/sbin/wan-static.sh $1
		;;
esac

exit 0
