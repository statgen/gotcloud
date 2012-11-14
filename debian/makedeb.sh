#!/bin/bash
#
#   Create a Debian and/or RPM package
#   Syntax:   makedeb.sh  [-rpm]  bin | test
#
medir=`dirname $0`
here=`pwd`
cd $medir
tempfiles="changelog control postinst rules"    # from file.bin or file.test
cd ..                           # Must be in debian parent directory
RPMDIR=
if [ "$1" = "-rpm" ]; then
  export RPMDIR=rpmbin
  shift
fi

#   Figure out package name
debpkg=$1
if [ "$#" -le "0" ]; then
  echo "Create a Debian and/or RPM package"
  echo ""
  echo "Syntax:   makedeb.sh  [-rpm] bin | test"
  exit 1
fi
for f in $tempfiles; do         # Create files for this package
  cp debian/$f.$debpkg debian/$f || exit 1
done

#   Build package
pkg=`grep Package: debian/control | sed -e 's/Package: //'`
#   Supress errors, usually warnings about duplicates, until I can figure out what's going on
dpkg-buildpackage -b -us -uc -rfakeroot 2> /tmp/errs

rm -f ../${pkg}*.changes debian/files
for f in $tempfiles; do         # Remove files we created above
  rm -f debian/$f
done
rm -rf /tmp/errs debian/tmp

echo "Package file now in `pwd`"
ls -la ${pkg}*.deb || exit 1

#   Get files from parent
if [ "$RPMDIR" != "" ]; then
  echo ""
  echo "Converting DEB into RPM"
  alien --to-rpm --scripts ${pkg}*.deb
  ls -la ${pkg}*.rpm
fi
