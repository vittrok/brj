#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

proto=`nvram get $1_protocol`
interface=`nvram get $1_ifname`
pptp_server=`nvram get $1_pptp_server`
pptp_type=`nvram get $1_pptp_type`

[ -z "$interface" ] && echo "Error: interface name for $1 not set in nvram!" && exit 1
[ "$proto" != "pptp" ] && echo "Error: incorrect protocol for $1 set in nvram!" && exit 1
[ -z "$pptp_server" ] && echo "Error: ip address of pptp server mast be set in for $1_pptp_server !" && exit 1

/usr/bin/logger -t ppptp-$1 "start pptp process for $1"

nvram set $1_ipaddr_t=
nvram set $1_gateway_t=
nvram set $1_pppdev_t=

/usr/local/sbin/conf-ppp.sh $1
/usr/local/sbin/conf-resolv.sh $1

case "$pptp_type" in
	static)
		/usr/local/sbin/wan-static.sh $1 && /usr/sbin/pppd file /tmp/ppp/ppp.conf.$1
		;;
	dhcp)
		/usr/local/sbin/wan-dhcp.sh $1 && /usr/sbin/pppd file /tmp/ppp/ppp.conf.$1
		;;
	*)
		echo "Error: pptp type (static|dhcp) must be set in $1_pptp_type" && exit 1
		;;
esac

exit 0
