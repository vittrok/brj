#!/ffp/bin/sh

# PROVIDE: optware
# BEFORE:
# REQUIRE:

. /ffp/etc/ffp.subr

# Script for ffp 0.5 to automatically install optware's ipkg package manage
# and start any installed optware services.
# 1. Install ffp 0.5 (see http://wiki.dns323.info/howto:ffp)
# 2. Copy this script to /ffp/start/optware.sh and make it executable
# 3. Reboot the NAS
# 4. Check the ffp.log on Volume_1 to see that it installed successfully
#
# Author: TonyT @ http://forum.dsmg600.info/p25180-Yesterday-23:23:10.html
# Modified by Uli Wolf <ffp@wolf-u.li> @ http://wolf-u.li:
#  - Copy contents of existing /opt to optware-directory
#  - Modified mount-process
#  - Slight modification of the installation as we can install to /opt
#
# Installing is only done the first reboot when optware is not installed,
# subsequent reboots only start the installed optware packages by executing
# the scripts in /opt/etc/init.d (which is optware's equivalent of ffp's
# /ffp/start).
#
# Once optware's ipkg is installed you can install optware packages by:
# 1. Telnet/SSH on the NAS
# 2. To retrieve the list of packages that are currently available do:
# 3.   $ ipkg update
# 4. To see the list of packages do:
#      $ ipkg list
# 5. To install an optware package do:
#      $ ipkg install <package_name>
#    Replace <package_name> with package name(s) you want to install. ipkg
#    automatically manages dependencies. For example, installing rtorrent will
#    automatically install libtorrent.
# 6. If you install a package that needs to be started when the NAS is
#    rebooted create a <name>.sh file with the commands to start it in
#    /opt/etc/init.d and chmod +x. On subsequent reboots /ffp/start/optware.sh
#    will execute them in the same way ffp executes the /ffp/start scripts.
#
# To uninstall optware:
# WARNING: This will delete the entire /opt directory which also contains any
# optware packages and configuration files you installed subsequently so be
# sure that is what you want to do!
# 1. Telnet/SSH onto the NAS
# 2. execute:
#      $ /ffp/start/opware.sh uninstall
# Uninstalling will:
# 1. Remove the optware ipkg directory it created in /ffp-Directory
# 2. Remove the /opt link it created
# 3. Remove the /ffp/etc/profile.d/optware_profile.sh file it created (this
#    gets executed by ffp 0.5 when a new shell is created, it adds /opt/bin
#    and /opt/sbin to the path)
# 4. performs a chmod -x /ffp/start/optware.sh so it will no longer execute
#
# To reinstall simply "chmod +x /ffp/start/optware.sh" and reboot again
# (or directly invoke "/ffp/start/optware.sh start").
#
# Known Issues
# 1. Consider setting TMPDIR environment variable in /etc/profile if the
#    default /tmp is too small for certain programs installed.
# 2. ipkg currently does not appear to work on the DNS-321 as it requires
#    libc.so.0 which is not available in the DNS-321's /lib and the one in
#    /ffp/lib appears incompatible and causes a floating point exception.

name="optware"
start_cmd="optware_start"
stop_cmd="optware_stop"
# status_cmd="optware_status"

# Location of optware package
# DNS-323/CH3SNAS:
OPTWARE_FEED_NAME="dns323"
OPTWARE_FEED=http://ipkg.nslu2-linux.org/feeds/optware/dns323/cross/unstable
# DNS-320/DNS-325/DNS-343/CH3MNAS:
#OPTWARE_FEED_NAME="cs08q1armel"
#OPTWARE_FEED=http://ipkg.nslu2-linux.org/feeds/optware/cs08q1armel/cross/unstable

# real path to optware
OPTWARE_PATH=/ffp/opt/optware

# Directory to put profile files that are executed by FFP 0.5
FFP_PROFILE_DIR="/ffp/etc/profile.d"

# The profile file for optware
OPTWARE_PROFILE="$FFP_PROFILE_DIR/optware.sh"

# Use symbolic link rather than mount for the /opt directory.
OPTWARE_USE_SYMBOLIC_LINK="0"

# reverse order of elements in a list
func_reverse_list()
{
	_list=
	while [ $# -gt 0 ]; do
		_list="$1 $_list"
		shift
	done
	echo $_list
}
# Links or Mounts the OPTWAREPATH to /opt
func_optware_createpath()
{
	# Move existing /opt away
	test -e /opt && mv /opt /opt.bak
	
	if [ $OPTWARE_USE_SYMBOLIC_LINK = "1" ]; then
		# create /opt link
		echo "    Running: ln -snf $OPTWARE_PATH /opt"
		ln -snf $OPTWARE_PATH /opt
	else
		# Mount the /opt directory 
		echo "    Running: mkdir -p /opt"
		mkdir -p /opt
		echo "    Running: mount --bind $OPTWARE_PATH /opt"
		mount --bind $OPTWARE_PATH /opt
		if [[ $? -ne 0 ]]; then
			return 1;
		fi
	fi
	# Did we move the existing /opt? Copy the contents to the new one
	test -e /opt.bak && mv /opt.bak/* /opt/ && rm -Rf /opt.bak
	# Fixes some issues if scripts are accessing "env"
	test -e /usr/bin/ || mkdir -p /usr/bin/
	test -e /usr/bin/ && ln -sf /ffp/bin/env /usr/bin/env
}

optware_install()
{
	echo "*   Installing optware..."
	optware_ipkg_name=`wget -qO- $OPTWARE_FEED/Packages | awk '/^Filename: ipkg-opt/ {print $2}'`
	if [ ! optware_ipkg_name ]; then
		echo "*     FAILED: Unable to locate ipkg-opt in $OPTWARE_FEED/Packages"
		return 1
	fi

	mkdir -p $OPTWARE_PATH
	cd $OPTWARE_PATH

	echo "*     Retrieving $OPTWARE_FEED/$optware_ipkg_name ..."
	wget $OPTWARE_FEED/$optware_ipkg_name
	if [ ! -f $OPTWARE_PATH/$optware_ipkg_name ]; then
		echo "*     FAILED: Unable to retrieve $OPTWARE_FEED/$optware_ipkg_name"
		return 1
	fi
    
	echo "*     Linking or Mounting $OPTWARE_PATH to /opt ..."
	func_optware_createpath
	
	# Unzip and extract the opt directory contained in data.tar.gz
	echo "*     Installing $OPTWARE_PATH/$optware_ipkg_name ..."
	zcat $OPTWARE_PATH/$optware_ipkg_name | tar -xOvf - ./data.tar.gz | zcat | tar -C / -xvf -
	
	if [ ! -d $OPTWARE_PATH/bin ]; then
		echo "*     FAILED: Unable to unzip $OPTWARE_PATH/$optware_ipkg_name"
		return 1
	fi
	
	rm $OPTWARE_PATH/$optware_ipkg_name

	# Configure as the default feed:
	echo "*     Adding default feed \"src $OPTWARE_FEED_NAME $OPTWARE_FEED\" to /opt/etc/ipkg.conf"
	echo "src $OPTWARE_FEED_NAME $OPTWARE_FEED" >> /opt/etc/ipkg.conf

	# Create a profile file that will set PATH to include optware.
	# This is executed when a shell is created by ffp 0.5.
	if [ -d $FFP_PROFILE_DIR ]; then
		cat > $OPTWARE_PROFILE << "profile"
# Profile for optware
# Created automatically by /ffp/start/optware.sh for ffp 0.5
if [ -d "/opt" ]; then
    PATH=/opt/bin:$PATH
    if [ $(/ffp/bin/id -u) -eq 0 ]; then
	PATH=/opt/sbin:$PATH
    fi
    export PATH
fi
profile
		# Make sure it is executable
		chmod +x $OPTWARE_PROFILE
		# Now load it
		$FFP_PROFILE_DIR/$OPTWARE_PROFILE
		echo "*     Installed optware profile at $OPTWARE_PROFILE"
	else
		echo "*     WARNING: Unable to install optware's profile $OPTWARE_PROFILE"
	fi

	# List available packages
	if [ -x /opt/bin/ipkg ]; then
		echo "*     Retrieving optware packages currently available:"
		echo "        /opt/bin/ipkg update"
		/opt/bin/ipkg update
		echo "*     Optware packages available for installation:"
		echo "        /opt/bin/ipkg list"
		echo "*     To install an optware package:"
		echo "        /opt/bin/ipkg install <package_name>"
		echo "      Replace <package_name> with package name(s) you want to install. ipkg automatically manages"
		echo "      dependencies. For example, installing rtorrent will automatically install libtorrent."
	else
		echo "*     WARNING: $ipkg_path/opt/bin/ipkg is not executable!"
	fi
}

optware_uninstall()
{
	echo "*   Uninstalling optware..."
	if [ -f $OPTWARE_PROFILE ]; then
		echo "*     Removing optware profile $OPTWARE_PROFILE"
		rm -f $OPTWARE_PROFILE
	fi
	if [ -L /opt ]; then
		echo "*     Removing optware link /opt"
		rm -f /opt
	elif [ -d /opt ]; then
		echo "*     Unmounting and removing optware directory /opt"
		umount /opt
		rmdir /opt
	fi
	if [ -d $OPTWARE_PATH ]; then
		echo "*     Deleting optware directory $OPTWARE_PATH"
		rm -rf $OPTWARE_PATH
	fi
	echo "*     Changing ffp optware script $0 to not be executable"
	chmod -x $0
	echo "*     To reinstall optware simply make $0 executable and reboot"
}

optware_start()
{
	if [ ! -d $OPTWARE_PATH ]; then
		optware_install
	else
		# Create /opt
		func_optware_createpath
	fi
    
	if [ -d $OPTWARE_PATH ]; then
		# Start all init scripts in /opt/etc/init.d
		# executing them in numerical order.
		# (Derived from http://trac.nslu2-linux.org/optware/browser/trunk/sources/ipkg-opt/rc.optware )
		if [ -d "/opt/etc/init.d" ]; then
			for f in /opt/etc/init.d/S??* ; do
				if [ -x "$f" ]; then
					echo "*   $f ..."
					$f start
				else
					echo "*   $f inactive"
				fi
			done
		fi
	else
		echo "*   optware not installed"
	fi
}

optware_stop()
{
	for f in $(func_reverse_list /opt/etc/init.d/S??*); do
		if [ -x "$f" ]; then
			$f stop
		fi
	done
	if [ -d /opt ]; then
		umount /opt
		rmdir /opt
	fi
}

case "$1" in
	uninstall)
		optware_uninstall
	;;
	*)
		run_rc_command "$1"
	;;
esac

