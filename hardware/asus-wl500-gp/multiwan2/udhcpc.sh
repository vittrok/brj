#!/bin/sh

# use options routes and msroutes for dhcp-routes

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1
[ -z "`nvram get ${interface}_wan_t`" ] && echo "Error: set wan name to if ${interface} in nvram" && exit 1

wan=`nvram get ${interface}_wan_t`
proto=`nvram get ${wan}_protocol`
LOG="/usr/bin/logger -t dhcpc-$wan"
resolv_conf=/tmp/resolv.conf.${wan}

if [ "$proto" = "dhcp" ]; then
	ip_old=`nvram get ${wan}_ipaddr_t`
	netmask_old=`nvram get ${wan}_netmask_t`
	gw_old=`nvram get ${wan}_gateway_t`
else
	ip_old=`nvram get ${wan}_sub_ipaddr_t`
	netmask_old=`nvram get ${wan}_sub_netmask_t`
	gw_old=`nvram get ${wan}_sub_gateway_t`
fi


case "$1" in
    # deconfig)
        # $LOG "start deconfigure ip address on interface $interface"
        # $LOG "deconfigure ip address on interface $interface"
        #
        # /sbin/ifconfig $interface 0.0.0.0
        #
        # $LOG "deconfigure routing and masquerade on interface $interface"
        # if [ ! -z "$ip_old" ]; then
        #	iptables -D INPUT -i $interface ! -d $ip_old -j DROP
        # 	iptables -t nat -D POSTROUTING -o $interface ! -s $ip_old -j SNAT --to-source $ip_old
        # 	#iptables -t nat -D POSTROUTING -o $interface ! -s $ip_old -j MASQUERADE
        # 	iptables -t nat -D PREROUTING -d $ip_old -j VSERVER
        # fi
        #
        # $LOG "deconfig ip address `nvram get ${wan}_ipaddr_t`"
        # if [ "$proto" = "dhcp" ]; then
        # 	nvram set ${wan}_ipaddr_t=
        # 	nvram set ${wan}_netmask_t=
        # 	nvram set ${wan}_gateway_t=
        # else
        # 	nvram set ${wan}_sub_ipaddr_t=
        # 	nvram set ${wan}_sub_netmask_t=
        # 	nvram set ${wan}_sub_gateway_t=
        # fi
        # ;;
    
    nak)                                                                                            
        $LOG "received a NAK: $message"
        ;; 

    renew|bound)
    
    	gw=`echo $router | awk '{print $1}'`
    
        if [ "$ip" = "$ip_old" ] && [ "$subnet" = "$netmask_old" ] && [ "$gw" = "$gw_old" ]; then
            $LOG "get renew for address `nvram get ${wan}_ipaddr_t` on interface $interface - no need change!"
            exit 0
        fi
        if [ "$gw" = "192.168.100.1" ] && [ "`nvram get ${wan}_fucking_terayon`" = "1" ]; then
            #$LOG "get renew from fucking terayon tj715x - no need change!"
            exit 0
        fi
        
        export `ipcalc -s -m -b $ip $subnet`
        
        $LOG "start configure interface $interface"
        
        if [ ! -z "$ip_old" ]; then
        
            $LOG "deconfigure old ip address on interface $interface"

            /sbin/ifconfig $interface 0.0.0.0
            
            $LOG "deconfigure old routing and masquerade on interface $interface"
            iptables -D INPUT -i $interface ! -d $ip_old -j DROP
            #iptables -t nat -D POSTROUTING -o $interface ! -s $ip_old -j SNAT --to-source $ip_old
            iptables -t nat -D POSTROUTING -o $interface ! -s $ip_old -j MASQUERADE
            iptables -t nat -D PREROUTING -d $ip_old -j VSERVER
        fi
        
        $LOG "configure address $ip/$subnet on interface $interface"
        
        /sbin/ifconfig $interface $ip broadcast $BROADCAST netmask $NETMASK
        
        [ "$proto" = "dhcp" ] && ip route replace $gw dev $interface
        
        $LOG "add routing and masquerade on interface $interface"
        
        iptables -I INPUT 2 -i $interface ! -d $ip -j DROP
        #iptables -t nat -A POSTROUTING -o $interface ! -s $ip -j SNAT --to-source $ip
        iptables -t nat -A POSTROUTING -o $interface ! -s $ip -j MASQUERADE
        iptables -t nat -A PREROUTING -d $ip -j VSERVER
        
        if [ "$proto" = "dhcp" ]; then
        	if [ ! -z `nvram get ${wan}_testip_1` ]; then
        		$LOG "set routes for test ip adresses"
            		ip route replace `nvram get ${wan}_testip_1` via $gw
            		ip route replace `nvram get ${wan}_testip_2` via $gw
        	fi
        
        	if [ ! -z "$dns" ] && [ -z `nvram get ${wan}_dns_1` ]; then
            		$LOG "change resolv.conf"
            		echo -n > $resolv_conf
            		for i in $dns ; do echo nameserver $i >> $resolv_conf ; done
        	fi
        
        	nvram set ${wan}_ipaddr_t=$ip
       		nvram set ${wan}_netmask_t=$subnet
        	nvram set ${wan}_gateway_t=$gw
        
        	/usr/local/sbin/setroute.sh $wan
        	/usr/local/sbin/dyndns.sh $wan &
        else
        
		nvram set ${wan}_sub_ipaddr_t=$ip                                                                                       
		nvram set ${wan}_sub_netmask_t=$subnet 
		nvram set ${wan}_sub_gateway_t=$gw
		
		/usr/local/sbin/subroute.sh $wan
	fi
	
        ;;
    
esac

exit 0
