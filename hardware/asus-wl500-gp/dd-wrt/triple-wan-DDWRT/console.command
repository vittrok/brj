
<< Hardware Config >>
-WRT54GL 
-dd-wrt.v24_mini_wrt54g 
-JFFS2 ENABLED 
-PORTS 4 VLAN2 
-PORTS 3 VLAN3 

<< File system space needed >>
How much JFFS Space free after cleaned?
896.00 KB / 572.00 KB this is with dual up and running! 

<< Console Command >>
nvram set vlan0ports="3 2 5*" 
nvram set vlan2ports="0 5" 
nvram set vlan2hwname="et0" 
nvram set vlan3ports="1 5" 
nvram set vlan3hwname="et0" 
cd /jffs
# Get the binary IPTables
wget http://www.jbarbieri.net/dd-wrt/scripts/iptables 
mkdir /jffs/scripts 
cd /jffs/scripts 
# Get the firewall.firewall script, change to v2.6 or v24 or v23, etc...
wget http://www.jbarbieri.net/dd-wrt/scripts/firewall.firewall-triple-v23 
mv firewall.firewall-triple-v23 firewall.firewall 
# Get the routes.firewall script, change also ...
wget http://www.jbarbieri.net/dd-wrt/scripts/routes-triple.firewall 
mv routes-triple.firewall routes.firewall 
# Get the DHCP script
wget http://www.jbarbieri.net/dd-wrt/scripts/udhcpc-wan2.script 
wget http://www.jbarbieri.net/dd-wrt/scripts/udhcpc-wan3.script 
chmod a+x /jffs/* 
chmod a+x /jffs/sciprts/* 
nvram set rc_startup='udhcpc -i vlan2 -s /jffs/scripts/udhcpc-wan2.script udhcpc -i vlan3 -s /jffs/sciprts/udhcpc-wan3.script'
echo "`date` Sleeping 30 seconds so nvram can get fully up to date" 
sleep 30 
/jffs/scripts/routes.firewall 
echo "`date` rc_startup is now completed" >> /var/log/messages' 
nvram set rc_firewall='/jffs/scripts/routes.firewall /jffs/scripts/firewall.firewall' 
nvram commit 
reboot 

