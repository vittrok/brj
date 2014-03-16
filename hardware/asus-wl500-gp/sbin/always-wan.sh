#!/bin/sh
#
# DESCRIPTION
# "alwayson" script for Asus wl500g router.
#
# Pings default gateway each INTERVAL seconds.
# If ping fails tries to update dhcp parameters.
#
#
# INSTRUCTIONS
# Put script in "/usr/local/sbin"
# Save flashfs:
#     flashfs save && flashfs commit && flashfs enable
# Reboot device
#     reboot

# Log to stderr as well as the system log
LOGGER_OPTIONS=-s

# Number of ping failures before interface restart
ATTEMPTS=5

# Ping check interval set in seconds
INTERVAL=3

# Ping timeout in seconds
TIMEOUT=10

# Number of packets in ping
PACKETS=1

# WAN interface name
WAN=vlan1

logger $LOGGER_OPTIONS "Ping ($PACKETS packets, $TIMEOUT s timeout) default gateway each $INTERVAL s"
logger $LOGGER_OPTIONS "    if $ATTEMPTS in row fail reset network connection"

# udhcpc command line
UDHCPC="udhcpc -R -i $WAN -p /var/run/udhcpc0.pid -s /tmp/udhcpc.script"

# Counter of subsequential ping failures
COUNTER=0

ME=`basename $0`
RUNNING=`ps | awk '/'"$ME"'/ {++x}; END {print x+0}'`
if [ "$RUNNING" -gt 3 ]; then
   logger $LOGGER_OPTIONS "Another instance of \"$ME\" is running"
   exit 1
fi

while sleep $INTERVAL
do
   TARGET=`ip route | awk '/default via/ {print $3}'`
   RET=`ping -w $TIMEOUT -c $PACKETS $TARGET 2> /dev/null | awk '/packets received/ {print $4}'`
   # desktop ping shows number of received packets in 4-th place instead of 3-rd in busybox
   # RET=`ping -c $PACKETS $TARGET 2> /dev/null | awk '/received/ {print $4}'`

   if [ -z $RET ]; then
      RET=0
   fi

   if [ $RET -ne $PACKETS ]; then
      # PING FAILED
      COUNTER=$((COUNTER+1))
      echo "Ping failed. COUNTER: $COUNTER"
   else
      # PING SUCCEED
      # enable to get messages on successful ping as well
      # logger "Network is up via $TARGET"
      echo "Network is up via $TARGET"
      COUNTER=0
   fi

   if [ "$COUNTER" -eq "$ATTEMPTS" ]; then
      COUNTER=0
      logger $LOGGER_OPTIONS "Ping failed $ATTEMPTS times, releasing IP address on $WAN"
      # ensure udhcpc is not running
      killall udhcpc 2> /dev/null
      logger $LOGGER_OPTIONS "Renewing IP address: $WAN"
      $UDHCPC
      logger $LOGGER_OPTIONS "Waiting 10 s..."
      sleep 10
   fi
done

