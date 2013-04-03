#!/bin/bash
#
#   Check the system for files needed by GotCloud
#
#   Usgae:   check_requirements.sh  [install_dir]
#
#     eg.    check_requirements.sh /gotcloud
#
#   install_dir defaults to /usr/local/gotcloud
#
banner="#============================================================"
TOP=/usr/local/gotcloud
if [ -r /gotcloud/bin/umake.pl ]; then
  TOP=/gotcloud
fi
if [ "$1" != "" ]; then
  TOP=$1
fi
BIN=$TOP/bin
SCRIPTS=$TOP/scripts
if [ ! -d $BIN ]; then
  echo "WARNING:  '$BIN' does not exist.  Continuing..."
fi

#================================================================
#   Check on Redhat or CentOS systems
#================================================================
if [ ! -d /etc/apt ]; then
    inst='sudo yum install'
    pinst='sudo rpm -i'

    echo $banner
    echo "#   We are not ready for non-Debian systems'"
    echo $banner
    exit 1
fi


#================================================================
#   Check on Debian systems
#================================================================
inst='sudo apt-get install'
pinst='sudo dpkg -i'

#   Sanity checks
t=`which java`
if [ "$t" = "" ]; then
  echo $banner
  echo "#   'java' is not installed, do '$inst java-common default-jre'"
  echo $banner
else
  echo "Good, you appear to have 'java' installed"
fi
t=`which make`
if [ "$t" = "" ]; then
  echo $banner
  echo "#   'make' is not installed, do '$inst make'"
  echo $banner
else
  echo "Good, you appear to have 'make' installed"
fi
ssl=n
if [ -f /lib/x86_64-linux-gnu/libssl.so.0.9.8 ]; then
  ssl=y
fi
if [ -f /lib/libssl.so.0.9.8 ]; then
  ssl=y
fi
if [ "$ssl" != "y" ]; then
  echo $banner
  echo "#   'libssl0.9.8' is not installed, do '$inst libssl0.9.8'"
  echo $banner
else
  echo "Good, you appear to have 'libssl' installed at the correct level"
fi

if [ -d $TOP/test/umake ]; then
  echo "Good, you appear to have 'gotcloud-test' installed"
  echo "Test this install:  $BIN/gotcloud align --test ~/testaligner"
  echo "                    $BIN/gotcloud snpcall --test ~/testsnpcall"
else
  echo $banner
  echo "#   '$TOP/test/umake' does not exist so you cannot test this install"
  echo "#   Install it by doing '$pinst gotcloud-test_*.deb'"
  echo $banner
fi

exit
