#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

LOG="/usr/bin/logger -t static-$1"

interface=`nvram get $1_ifname`

[ -z "$interface" ] && echo "Error: interface name for $1 not set in nvram!" && exit 1

proto=`nvram get $1_protocol`

case "$proto" in

	static)	
		ip=`nvram get $1_ipaddr_t`
		subnet=`nvram get $1_netmask_t`
		gw=`nvram get $1_gateway_t`
		[ -z "$gw" ] && echo "Error: gateway for $1 not set $1_gateway_t !" && exit 1
		;;
		
	pppoe)
		ip=`nvram get $1_sub_ipaddr_t`
		subnet=`nvram get $1_sub_netmask_t`
		;;
		
	pptp)
		ip=`nvram get $1_sub_ipaddr_t`
		subnet=`nvram get $1_sub_netmask_t`
		[ -z "`nvram get $1_pptp_server`" ] && echo "Error: ip address of pptp server must be set in for $1_pptp_server !" && exit 1
		;;
		
	*)
		echo "Error: incorrect protocol for $1 set in nvram!"
		exit 1
		;;
		
esac
		
[ -z "$ip" ] && echo "Error: ip address for $1 not set in nvram!" && exit 1

$LOG "start configure interface $interface"

export `ipcalc -s -m -b $ip $subnet`

$LOG "configure address $ip/$subnet on interface $interface"

/sbin/ifconfig $interface 0.0.0.0
/sbin/ifconfig $interface $ip broadcast $BROADCAST netmask $NETMASK

$LOG "add routing and masquerade on interface $interface"

iptables -I INPUT 2 -i $interface ! -d $ip -j DROP
#iptables -t nat -A POSTROUTING -o $interface ! -s $ip -j MASQUERADE
iptables -t nat -A POSTROUTING -o $interface ! -s $ip -j SNAT --to-source $ip
iptables -t nat -A PREROUTING -d $ip -j VSERVER

if [ "$proto" = "static" ]; then
	
	ip route replace $gw dev $interface
	
	if [ ! -z `nvram get $1_testip_1` ]; then
		ip route replace `nvram get $1_testip_1` via $gw
		ip route replace `nvram get $1_testip_2` via $gw
	fi

	/usr/local/sbin/conf-resolv.sh $1
	/usr/local/sbin/setroute.sh $1
	/usr/local/sbin/dyndns.sh $1 &
else
	/usr/local/sbin/subroute.sh $1
fi

$LOG "finish configure interface $interface"

exit 0
