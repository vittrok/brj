#!/bin/sh

[ -z "$1" ] && echo "Error: should be called from ppp-ip-up or wan-<proto>.sh" && exit 1

proto=`nvram get $1_protocol`
interface=`nvram get $1_ifname`
add_sub_route=/usr/local/routes/route.sub.$1

if [ "$proto" = "pptp" ]; then

	pptp_gw=`nvram get $1_pptp_gw`
	pptp_server=`nvram get $1_pptp_server`
	
	if [ ! -z "$pptp_server" ]; then
		if [ ! -z "$pptp_gw" ]; then
			ip route replace $pptp_gw dev $interface
			ip route replace $pptp_server via $pptp_gw
		else
			ip route replace $pptp_server dev $interface
		fi
	fi
fi

[ -x $add_sub_route ] && $add_sub_route

exit 0
