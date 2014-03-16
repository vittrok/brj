#!/bin/sh

dgw_sem=/tmp/def.route
sip_sem=/tmp/sip.route

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

	ip route flush exact 0/0
	ip route replace default via $gw
	ip route flush cache

	$LOG "done change route"
	
	if [ -z `nvram get master_dns_1` ]; then 
	
		$LOG "change /etc/resolv.conf"
		cp /tmp/resolv.conf.$1 /tmp/resolv.conf > /dev/null 2>&1
		kill -HUP `pidof dnsmasq`
	fi
	
	# fucking sip phones and ip_conntrack
	#flushconntrack_def

	rm ${dgw_sem}.* > /dev/null 2>&1
	touch ${dgw_sem}.$1
	
	return 0
}

unsetdefgw()
{
	$LOG "ALL wan pors fail! unset default gateway"
	
	ip route flush exact 0/0 table primary
	
	$LOG "done delete route"
	
	rm ${dgw_sem}.* > /dev/null 2>&1
	touch ${dgw_sem}.none
	
	return 0
}

setsipgw()
{
	[ -z "$1" ] && $LOG "Error: wan interface name must be set!" && return 1
	
	gw=`nvram get $1_gateway_t`
	
	[ -z "$gw" ] && $LOG "ERROR! gateway for $1 not set in nvram!" && return 1
	
	$LOG "set SIP route to $1"
	$LOG "add SIP route to routing table"

	ip route flush exact 0/0 table voip
	ip route replace default via $gw table voip
	
	flushconntrack
	
	ip route flush cache
	
	rm ${sip_sem}.* > /dev/null 2>&1
	touch ${sip_sem}.$1
	
	$LOG "done add SIP route"
	
	return 0
}

flushconntrack_def()
{
	for wan in `ls ${dgw_sem}.* | sed -e 's/\/tmp\/def\.route\.//g` ; do
		
		proto=`nvram get ${wan}_protocol`
		
		case "$proto" in
		
			static|dhcp)
			 
				gw=`nvram get ${wan}_gateway_t`
				interface=`nvram get ${wan}_ifname`
				additional_route=/usr/local/routes/route.${wan}
				
				$LOG "flush ip_conntrack entries for $interface by down/up interface"
				
				/sbin/ifconfig $interface down
				/sbin/ifconfig $interface up
				
				$LOG "restore routes for $wan"
				
				ip route replace $gw dev $interface
				
				if [ ! -z `nvram get ${wan}_testip_1` ]; then
					$LOG "restore routes for test ip adresses for $wan"
					ip route replace `nvram get ${wan}_testip_1` via $gw
					ip route replace `nvram get ${wan}_testip_2` via $gw
				fi
				
				[ -x $additional_route ] && $additional_route
				;;
				
			pptp|pppoe)
				
				$LOG "send HUP signal to pppd on int $interface"
				
				[ -f /var/run/ppp-${wan}.pid ] && kill -HUP `head -n 1 /var/run/ppp-${wan}.pid`
				;;
		esac
	done
	
	return 0
}

flushconntrack()
{
	for wan in `ls ${sip_sem}.* | sed -e 's/\/tmp\/sip\.route\.//g` ; do
		
		gw=`nvram get ${wan}_gateway_t`
		proto=`nvram get ${wan}_protocol`
		additional_route=/usr/local/routes/route.${wan}
		
		case "$proto" in
			static|dhcp)
				interface=`nvram get ${wan}_ifname`
				;;
			pptp|pppoe)
				interface=`nvram get ${wan}_pppdev_t`
				;;
		esac
		
		#route=`ip ro list | grep $interface`
		defgw=`ip ro list exact 0/0 table all | grep $interface`
		
		$LOG "flush ip_conntrack entries for $interface by down/up interface"
		
		/sbin/ifconfig $interface down
		/sbin/ifconfig $interface up
		
		ip route replace $gw dev $interface
		
		#echo "$route" | awk '{print "ip route replace "$0}' | /bin/sh
		#echo "$route" | awk '{print "restore route "$0}' | $LOG 
		
		if [ ! -z "$defgw" ]; then 
			echo "$defgw" | awk '{print "ip route replace "$0}' | /bin/sh
			echo "$defgw" | awk '{print "restore route "$0}' | $LOG
		fi
			
		if [ ! -z `nvram get ${wan}_testip_1` ]; then
			$LOG "restore routes for test ip adresses for $wan"
			ip route replace `nvram get ${wan}_testip_1` via $gw
			ip route replace `nvram get ${wan}_testip_2` via $gw
		fi
		
		[ -x $additional_route ] && $additional_route
	done
	
	return 0
}
		

# default route

if   [ -f $wan1_sem ]; then [ ! -f ${dgw_sem}.wan1 ] && setdefgw wan1
elif [ -f $wan2_sem ]; then [ ! -f ${dgw_sem}.wan2 ] && setdefgw wan2
#elif [ -f $wan3_sem ]; then [ ! -f ${dgw_sem}.wan3 ] && setdefgw wan3
#else flushconntrack_def; rm ${dgw_sem}.* > /dev/null 2>&1
else rm ${dgw_sem}.* > /dev/null 2>&1
fi

# sip route

# if   [ -f $wan2_sem ]; then [ ! -f ${sip_sem}.wan2 ] && setsipgw wan2                               
# elif [ -f $wan1_sem ]; then [ ! -f ${sip_sem}.wan1 ] && setsipgw wan1                                          
# #else flushconntrack; rm ${sip_sem}.* > /dev/null 2>&1                                       
# fi


$LOG "switch rouing process finish"

exit 0
