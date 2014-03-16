#!/bin/sh

[ -z "$1" ] && echo "Error: should be called from ppp-ip-up or cl-<proto>.sh" && exit 1

proto=`nvram get $1_protocol`
interface=`nvram get $1_ifname`
add_sub_route=/usr/local/routes/route.sub.$1

if [ "$proto" = "pptp" ]; then
	pptp_gw=`nvram get $1_pptp_gw`
	pptp_server=`nvram get $1_pptp_server`
	[ ! -z "$pptp_server" ] && ( [ ! -z "$pptp_gw" ] && ip route replace $pptp_server via $pptp_gw || ip route replace $pptp_server dev $interface )
fi

[ -x $add_sub_route ] && $add_sub_route

exit 0
