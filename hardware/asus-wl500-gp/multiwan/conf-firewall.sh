#!/bin/sh

IPT_POS="-n --line-numbers | grep 'state RELATED,ESTABLISHED' | awk '{print \$1}'"
IPT_FWP=$(expr `eval iptables -L FORWARD $IPT_POS` + 1)
IPT_INP=$(expr `eval iptables -L INPUT $IPT_POS` + 3)

iptables -D INPUT -i vlan1 -m state --state NEW -j SECURITY
iptables -D FORWARD -i vlan1 -m state --state NEW -j SECURITY
iptables -D INPUT -p udp --sport 67 --dport 68 -j ACCEPT

iptables -I INPUT $IPT_INP -i vlan+ -m state --state NEW -j SECURITY
iptables -I INPUT $IPT_INP -i ppp+ -m state --state NEW -j SECURITY
iptables -I FORWARD $IPT_FWP -i vlan+ -m state --state NEW -j SECURITY
iptables -I FORWARD $IPT_FWP -i ppp+ -m state --state NEW -j SECURITY
