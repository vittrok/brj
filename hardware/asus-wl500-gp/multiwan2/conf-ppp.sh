#!/bin/sh

[ -z "$1" ] && echo "Error: WAN name must be set!" && exit 1

proto=`nvram get $1_protocol`
interface=`nvram get $1_ifname`
ppp_conf=/tmp/ppp/ppp.conf.$1

case "$proto" in
	pppoe)
		username=`nvram get $1_pppoe_username`
		password=`nvram get $1_pppoe_password`
		options=`nvram get $1_pppoe_extra`
		pppoe_acn=`nvram get $1_pppoe_acn`
		pppoe_srv=`nvram get $1_pppoe_srv`
		pppoe_mtu=`nvram get $1_pppoe_mtu`
		pppoe_mru=`nvram get $1_pppoe_mru`
		pppoe_opt="nic-$interface"
		[ ! -z "$pppoe_acn" ] && pppoe_opt="rp_pppoe_ac '$pppoe_acn' $pppoe_opt"
		[ ! -z "$pppoe_srv" ] && pppoe_opt="rp_pppoe_service '$pppoe_srv' $pppoe_opt"
		ppp_opt="plugin rp-pppoe.so $pppoe_opt"
		;;
	pptp)
		username=`nvram get $1_pptp_username`
		password=`nvram get $1_pptp_password`
		options=`nvram get $1_pptp_extra`
		pptp_mtu=`nvram get $1_pptp_mtu`
		pptp_server=`nvram get $1_pptp_server`
		ppp_opt="pty '/usr/sbin/pptp --idle-wait 0 $pptp_server --nolaunchpppd --nobuffer --sync --loglevel 0'"
		;;
esac
	
echo -n > $ppp_conf 
echo "noauth refuse-eap" >> $ppp_conf
echo "user '$username'" >> $ppp_conf 
echo "password '$password'" >> $ppp_conf 
echo "ipparam $1" >> $ppp_conf
echo "linkname $1" >> $ppp_conf
echo "$ppp_opt" >> $ppp_conf

case "$proto" in
	pppoe)
		echo "nomppe nomppc" >> $ppp_conf
		echo "mru $pppoe_mru mtu $pppoe_mtu" >> $ppp_conf
		;;
	pptp)
		echo "lock" >> $ppp_conf
		echo "connect true" >> $ppp_conf
		echo "nomppe-stateful mtu $pptp_mtu" >> $ppp_conf
		;;
esac

echo "nodetach" >> $ppp_conf
echo "maxfail 30" >> $ppp_conf
echo "usepeerdns" >> $ppp_conf
echo "nodefaultroute" >> $ppp_conf
echo "persist" >> $ppp_conf
echo "ipcp-accept-remote ipcp-accept-local noipdefault" >> $ppp_conf
echo "ktune" >> $ppp_conf
echo "default-asyncmap nopcomp noaccomp" >> $ppp_conf
echo "novj nobsdcomp nodeflate" >> $ppp_conf
echo "lcp-echo-interval 10" >> $ppp_conf
echo "lcp-echo-failure 3" >> $ppp_conf
[ ! -z "$options" ] && echo "$options"  >> $ppp_conf
echo "ip-up-script /usr/local/sbin/ppp-ip-up" >> $ppp_conf
echo "ip-down-script /usr/local/sbin/ppp-ip-down" >> $ppp_conf


exit 0
