#!/bin/sh

if [ `ps | grep -c pptp` -ge 20 ]; then
	logger -t pptp-wg "too many pptp process! KILL ALL!!"
	killall pptp
fi

exit 0
