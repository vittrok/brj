#!/bin/sh

# Collect dns-323 box temperature
echo -n "temp: "
/ffp/bin/dns323-temp | awk {'print $1'}

# Collect HHD1 + HDD2 temperature
echo -n "hdd1 "
smartctl -d marvell -a -i /dev/sda | grep "Temp" | awk '{print $10}'
echo -n "hdd2 "
smartctl -d marvell -a -i /dev/sdb | grep "Temp" | awk '{print $10}'

# Collect dns-323 fan rotatator :-)
echo -n "rotatator: "
/ffp/bin/dns323-fan | awk {'print $2'}

# Collect network bandwith
ifconfig "egiga0" | grep bytes | awk -F ":" '{print $2}' | awk '{print $1}'
ifconfig "egiga0" | grep bytes | awk -F ":" '{print $3}' | awk '{print $1}'

