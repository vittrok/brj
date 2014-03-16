#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

dns1=`nvram get $1_dns_1`
dns2=`nvram get $1_dns_2`

if [ ! -z "$dns1" ]; then
	echo -n > /tmp/resolv.conf.$1
	echo "nameserver $dns1" >> /tmp/resolv.conf.$1
	[ ! -z "$dns2" ] && echo "nameserver $dns2" >> /tmp/resolv.conf.$1
fi

exit 0
