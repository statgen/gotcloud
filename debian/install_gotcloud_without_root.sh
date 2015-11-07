#!/bin/bash
#
#   Install the gotcloud deb files as a non-root user
#
tempdir=/tmp/$$.gotcloud.removeme

if [ "$#" -le "1" ]; then
  echo "Usage: $0 version  dest-dir"
  echo ""
  echo "Install the gotcloud packages without root authority"
  echo "You must be in the directory where the gotcould*.deb file lives"
  echo "E.g."
  echo "cd /tmp"
  echo "$0  1.06  ~/gotcloud    # Creates $HOME/gotcloud"
  exit 1
fi
ver=$1
destdir=$2

#
pkgs="gotcloud-bin_${ver}_amd64.deb gotcloud-test_${ver}_amd64.deb"

mkdir -p $destdir/gotcloud || exit 1

for pkg in $pkgs; do
  echo "Installing '$pkgs' into '$destdir'"
  rm -rf $tempdir
  dpkg -x $pkg $tempdir || exit 1
  rsync -av --delete $tempdir/usr/local/gotcloud/* $destdir/gotcloud || exit 1
done
rm -rf $tempdir

#   Sanity check to see if you have the requirements
echo ""
echo ""
$destdir/gotcloud/scripts/check_requirements.sh $destdir/gotcloud/

