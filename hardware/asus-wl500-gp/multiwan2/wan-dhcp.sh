#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

proto=`nvram get $1_protocol`
interface=`nvram get $1_ifname`
dhcpflag=/tmp/dhcp.$1.ping

[ -z "$interface" ] && echo "Error: interface name for $1 not set in nvram!" && exit 1
[ "$proto" = "static" ] && echo "Error: incorrect protocol for $1 set in nvram!" && exit 1

nvram set ${interface}_wan_t=$1

/usr/bin/logger -t dhcp-$1 "start dhcp process for $1"

if [ "$proto" = "dhcp" ]; then
	nvram set $1_ipaddr_t=
	nvram set $1_netmask_t=
	nvram set $1_gateway_t=
	
	/usr/local/sbin/conf-resolv.sh $1
	
else
	nvram set $1_sub_ipaddr_t=
	nvram set $1_sub_netmask_t=
	nvram set $1_sub_gateway_t=
fi

ifconfig $interface 0.0.0.0

iptables -A INPUT -p udp -i $interface --sport 67 --dport 68 -j ACCEPT

udhcpc -b -p /tmp/udhcpc.$1.pid -i $interface -s /usr/local/sbin/udhcpc.sh

/usr/local/sbin/dhcping.sh $1 &
#[ ! -f $dhcpflag ] && touch $dhcpflag && /usr/local/sbin/dhcping.sh $1 &

exit 0
