kill -9 $(ps|grep pppd|awk -F' ' '{print $1}') 2>/dev/null
mkdir /tmp/ppp/
mkdir /tmp/ppp/peers/
apn=$(nvram get apn)
dialnumber=$(nvram get dialnumber)
modem=$(nvram get modem)
username=$(nvram get username)
port=$(nvram get port)
portspeed=$(nvram get portspeed)
password=$(nvram get password)
vend=$(nvram get vend)
prod=$(nvram get prod)
mtu=$(nvram get mtu)
mru=$(nvram get mru)
atinit=$(nvram get atinit)
if [ "$vend" == "" -o "$prod" == "" ]; then
 insmod acm
 insmod usbserial
 insmod option
 insmod pl2303
 insmod ftdi_sio
else
 insmod usbserial vendor=$vend product=$prod maxSize=4096
fi
sleep 15
usbdev=$(cat /proc/bus/usb/devpath | grep -o "/.*" | awk -F 'm' '{print $1}')
echo "'' ''" > /tmp/ppp/peers/cdma.chat
echo "'' 'ATZ'" >> /tmp/ppp/peers/cdma.chat
echo "$atinit" >> /tmp/ppp/peers/cdma.chat
echo "'OK' 'ATD #777'" >> /tmp/ppp/peers/cdma.chat
echo "'CONNECT' ''" >> /tmp/ppp/peers/cdma.chat
echo "'' ''" > /tmp/ppp/peers/gprs.chat
echo "'' 'ATZ'" >> /tmp/ppp/peers/gprs.chat
echo "$atinit" >> /tmp/ppp/peers/cdma.chat
echo "'' 'AT+CGDCONT=1,\"IP\",\"$apn\"'" >> /tmp/ppp/peers/gprs.chat
echo "'OK' 'ATD$dialnumber'" >> /tmp/ppp/peers/gprs.chat
echo "'CONNECT' ''" >> /tmp/ppp/peers/gprs.chat
echo "debug" > /tmp/ppp/peers/$modem
if [ "$usbdev" == "/dev/usb/ac" ]; then
 echo "/dev/usb/acm/$port" >> /tmp/ppp/peers/$modem
else
 echo "/dev/usb/tts/$port" >> /tmp/ppp/peers/$modem
fi
echo "$portspeed" >> /tmp/ppp/peers/$modem
echo "crtscts" >> /tmp/ppp/peers/$modem
echo "noipdefault" >> /tmp/ppp/peers/$modem
echo "ipcp-accept-local" >> /tmp/ppp/peers/$modem
echo "lcp-echo-interval 60" >> /tmp/ppp/peers/$modem
echo "lcp-echo-failure 6" >> /tmp/ppp/peers/$modem
echo "mtu $mtu" >> /tmp/ppp/peers/$modem
echo "mru $mru" >> /tmp/ppp/peers/$modem
echo "usepeerdns" >> /tmp/ppp/peers/$modem
echo "noauth" >> /tmp/ppp/peers/$modem
echo "nodetach" >> /tmp/ppp/peers/$modem
echo "persist" >> /tmp/ppp/peers/$modem
echo "user '$username'" >> /tmp/ppp/peers/$modem
echo "password '$password'" >> /tmp/ppp/peers/$modem
echo "connect \"/usr/sbin/chat -s -S -V -t 60 -f /tmp/ppp/peers/$modem.chat 2>/tmp/chat.log\"" >> /tmp/ppp/peers/$modem
pppd call $modem >> /tmp/chat.log
route add -net 172.16.0.0 netmask 255.255.0.0 gw 172.16.106.1
iptables -A FORWARD -i br0 -o ppp0 -j ACCEPT
iptables -A FORWARD -i br0 -o vlan1 -j ACCEPT
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o vlan1 -j MASQUERADE
kill -9 $(ps|grep pppd|awk -F' ' '{print $1}') 2>/dev/null
mkdir /tmp/ppp/
mkdir /tmp/ppp/peers/
apn=$(nvram get apn)
dialnumber=$(nvram get dialnumber)
modem=$(nvram get modem)
username=$(nvram get username)
port=$(nvram get port)
portspeed=$(nvram get portspeed)
password=$(nvram get password)
vend=$(nvram get vend)
prod=$(nvram get prod)
mtu=$(nvram get mtu)
mru=$(nvram get mru)
atinit=$(nvram get atinit)
if [ "$vend" == "" -o "$prod" == "" ]; then
 insmod acm
 insmod usbserial
 insmod option
 insmod pl2303
 insmod ftdi_sio
else
 insmod usbserial vendor=$vend product=$prod maxSize=4096
fi
sleep 15
usbdev=$(cat /proc/bus/usb/devpath | grep -o "/.*" | awk -F 'm' '{print $1}')
echo "'' ''" > /tmp/ppp/peers/cdma.chat
echo "'' 'ATZ'" >> /tmp/ppp/peers/cdma.chat
echo "$atinit" >> /tmp/ppp/peers/cdma.chat
echo "'OK' 'ATD #777'" >> /tmp/ppp/peers/cdma.chat
echo "'CONNECT' ''" >> /tmp/ppp/peers/cdma.chat
echo "'' ''" > /tmp/ppp/peers/gprs.chat
echo "'' 'ATZ'" >> /tmp/ppp/peers/gprs.chat
echo "$atinit" >> /tmp/ppp/peers/cdma.chat
echo "'' 'AT+CGDCONT=1,\"IP\",\"$apn\"'" >> /tmp/ppp/peers/gprs.chat
echo "'OK' 'ATD$dialnumber'" >> /tmp/ppp/peers/gprs.chat
echo "'CONNECT' ''" >> /tmp/ppp/peers/gprs.chat
echo "debug" > /tmp/ppp/peers/$modem
if [ "$usbdev" == "/dev/usb/ac" ]; then
 echo "/dev/usb/acm/$port" >> /tmp/ppp/peers/$modem
else
 echo "/dev/usb/tts/$port" >> /tmp/ppp/peers/$modem
fi
echo "$portspeed" >> /tmp/ppp/peers/$modem
echo "crtscts" >> /tmp/ppp/peers/$modem
echo "noipdefault" >> /tmp/ppp/peers/$modem
echo "ipcp-accept-local" >> /tmp/ppp/peers/$modem
echo "lcp-echo-interval 60" >> /tmp/ppp/peers/$modem
echo "lcp-echo-failure 6" >> /tmp/ppp/peers/$modem
echo "mtu $mtu" >> /tmp/ppp/peers/$modem
echo "mru $mru" >> /tmp/ppp/peers/$modem
echo "usepeerdns" >> /tmp/ppp/peers/$modem
echo "noauth" >> /tmp/ppp/peers/$modem
echo "nodetach" >> /tmp/ppp/peers/$modem
echo "persist" >> /tmp/ppp/peers/$modem
echo "user '$username'" >> /tmp/ppp/peers/$modem
echo "password '$password'" >> /tmp/ppp/peers/$modem
echo "connect \"/usr/sbin/chat -s -S -V -t 60 -f /tmp/ppp/peers/$modem.chat 2>/tmp/chat.log\"" >> /tmp/ppp/peers/$modem
pppd call $modem >> /tmp/chat.log

