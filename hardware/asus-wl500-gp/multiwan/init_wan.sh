#!/bin/sh

LOG="/usr/bin/logger -t init-wan"

if [ "`nvram get wan_ipaddr`" != "0.0.0.0" ] || [ "`nvram get wan_proto`" != "static" ]; then
	$LOG "ERROR!!! for use multi-WAN scripts set in web interface 'IP Address' to '0.0.0.0' and 'WAN Connection Type' to 'Static IP'"
	exit 1
fi

$LOG "start launch multi-wan"

# deconfigure vlan1 (default wan)

ifconfig vlan1 down

/usr/local/sbin/conf-firewall.sh

while /sbin/route delete default > /dev/null 2>&1 ; do : ; done

# start route daemon
/usr/local/sbin/routed.sh &

# set master dns
mdns1=`nvram get master_dns_1`
mdns2=`nvram get master_dns_2`

if [ ! -z "$mdns1" ]; then
	echo -n > /tmp/resolv.conf
	echo "nameserver $mdns1" >> /tmp/resolv.conf
	[ ! -z "$mdns2" ] && echo "nameserver $mdns2" >> /tmp/resolv.conf
	kill -HUP `pidof dnsmasq`
fi

# set routes

for i in `seq 1 5`; do

	proto=`nvram get wan${i}_protocol`
	interface=`nvram get wan${i}_ifname`
	mac_addr=`nvram get wan${i}_macaddr_x`
	
	if [ ! -z "$interface" -a ! -z "$mac_addr" ]; then 
		if [ "$interface" = "vlan1" ]; then
			$LOG "WARNING! For set mac-address for interface vlan1 use web-interface or set wan_hwaddr_x= in nvram!"
		else
			ifconfig $interface hw ether $mac_addr
		fi
	fi
	
	case "$proto" in
		pptp)
			pptp_server=`nvram get wan${i}_pptp_server`
			[ ! -z "$pptp_server" ] && ip route replace $pptp_server via 127.0.0.1
			;;
			
		pppoe)
			[ -z "`nvram get wan${i}_pppoe_mtu`" ] && nvram set wan${i}_pppoe_mtu=1492
			[ -z "`nvram get wan${i}_pppoe_mru`" ] && nvram set wan${i}_pppoe_mru=1492
			;;
	esac

	if [ ! -z "`nvram get wan${i}_testip_1`" ]; then
	
		ip route replace `nvram get wan${i}_testip_1` via 127.0.0.1
		ip route replace `nvram get wan${i}_testip_2` via 127.0.0.1
		
		(sleep 60 && /usr/local/sbin/pinger.sh wan${i}) &
	fi
	
	case "$proto" in
		static)
			/usr/local/sbin/wan-static.sh wan${i}
			;;
			
		dhcp)
			/usr/local/sbin/wan-dhcp.sh wan${i}
			;;
			
		pptp)
			/usr/local/sbin/wan-pptp.sh wan${i}
			;;
			
		pppoe)
			/usr/local/sbin/wan-pppoe.sh wan${i}
			;;
	esac
	
done

$LOG "finish launch multi-wan"

exit 0
