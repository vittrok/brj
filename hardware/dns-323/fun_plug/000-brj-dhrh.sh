#!/ffp/bin/sh

# PROVIDE: brj-dtrh

. /ffp/etc/ffp.subr

name="dtrh"
start_cmd="dtrh_start"
stop_cmd="dtrh_stop"

dtrh_start()
{

    # Do the right think! :-)	

    # Start syglog
    killall -9 syslogd
    killall -9 syslog-ng
    /opt/sbin/syslog-ng

    # Kill lpd. it's sux.
    killall -9 lpd

    # Do better samba
    smb stop
    cp /mnt/HD_a2/ffp/brj/smb.conf /etc/samba
    smb start

    # do better crontab for root
    killall -9 crond
    cp /ffp/brj/cron/root /var/spool/cron/crontabs
    crond

    # Done!

}

dtrh_stop()
{

	# Stop DTRH

	echo "wow! :-)"

}

run_rc_command "$1"
