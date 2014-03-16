#!/bin/sh

[ -z "$1" ] && echo "Error: wan name must be set in arg" && exit 1

ip=`nvram get $1_ipaddr_t`
hostname=`nvram get ddns_hostname_$1`

if [ ! -z "$hostname" ] && [ ! -z "$ip" ]; then
	logger -t dyndns-$1 "update DynDNS account host $hostname to ip address $ip"
	/usr/sbin/ez-ipupdate -q -a $ip -b /tmp/ez-ipupdate.$1.cache -M 864000 -S dyndns \
	-h $hostname -u `nvram get ddns_username_x`:`nvram get ddns_passwd_x`
fi

exit 0
