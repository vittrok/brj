#!/bin/sh

for i in `seq 1 5`; do
	[ ! -z "`nvram get ddns_hostname_wan${i}`" ] && /usr/local/sbin/dyndns.sh wan${i}
done

exit 0
