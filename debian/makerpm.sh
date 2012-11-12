#!/bin/bash
#
#   Create an RPM package by making a DEB and converting it
#   
#   Syntax:   makerpm.sh align | test
#
d=`dirname $0`
cd $d || exit 1
./makedeb.sh -rpm $*
