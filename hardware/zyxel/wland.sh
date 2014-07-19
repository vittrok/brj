#!/bin/sh

# cron script for checking wlan connectivity
# change 192.168.1.1 to whatever IP you want to check.

IP_FOR_TEST="192.168.1.1"
PING_COUNT=3

PING="/bin/ping"
IFUP="/sbin/ifup"
IFDOWN="/sbin/ifdown --force"

INTERFACE="wlan1"

FFLAG="/tmp/stuck.fflg"

# ping test
$PING -c $PING_COUNT $IP_FOR_TEST > /dev/null 2> /dev/null
if [ $? -ge 1 ]
then
    logger "$INTERFACE seems to be down, trying to bring it up..."
        if [ -e $FFLAG ]
        then
                logger "$INTERFACE is still down, REBOOT to recover ..."
                rm -f $FFLAG 2>/dev/null
                reboot
        else
                touch $FFLAG
                logger $($IFDOWN $INTERFACE)
                sleep 10
                logger $($IFUP $INTERFACE)
        fi
else
#    logger "$INTERFACE is up"
    rm -f $FFLAG 2>/dev/null
fi
