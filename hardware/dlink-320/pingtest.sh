#!/bin/bash
while true
do
if ping -c 1 -s 1 -W 1 -I vlan1 172.16.5.3
then
    route add default gw 172.16.106.1
    iptables -t nat -A POSTROUTING -o vlan1 -j MASQUERADE
else
    route del default gw 172.16.106.1
    iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
fi
sleep 2
done





