## midc ##

# to apt-
# lasted mc release
deb http://www.tataranovich.com/debian wheezy main
deb-src http://www.tataranovich.com/debian wheezy main

# to shell
apt-get remove mc
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 2EE7EF82
apt-get install mc

# to bash
alias mc='env TERM=xterm-256color mc -a'

# in mc
set theme modarin256root
