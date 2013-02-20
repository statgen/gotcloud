#!/bin/bash
#
#   Create a Debian and/or RPM package
#
#   Debian dependencies:
#       debhelper
#       zlib1g-dev
#       libncurses5-dev
#
medir=`dirname $0`
here=`pwd`
cd $medir
tempfiles="changelog control postinst rules postrm "    # from file.bin or file.test
cd ..                           # I must be in debian parent directory

#----------------------------------------------------------------
#   Poor man's way to handle options
#----------------------------------------------------------------
RPMDIR=
if [ "$1" = "-rpm" ]; then
  export RPMDIR=rpmbin
  shift
fi
replace=n
if [ "$1" = "-replace" ]; then
  replace=y
  shift
fi

#----------------------------------------------------------------
#   Figure out parameters
#----------------------------------------------------------------
debpkg=$1
version=$2
if [ "$#" -le "1" ]; then
  echo "Create a Debian and/or RPM package"
  echo ""
  echo "Syntax:   makedeb.sh  [-rpm] [-replace] [ bin | test ] version"
  exit 1
fi

#   See if this is supposed to be a new version or what
vf=release_version.txt
v=`cat $vf`
if [ "$v" = "" ]; then
  echo "Version is not set in '$vf'.  Something is messed up"
  exit 3
fi
if [ "$v" != "$version" ]; then
  echo "Is this a new version for the package?"
  echo "  $vf says '$v'"
  echo "  but you said the version is '$version'"
  echo ""
  echo "Please specify:"
  echo "  q - quit"
  echo "  u - use this version for now, but do not set $vf"
  echo "  n - new version, set $vf to use this"  
  echo -n "What do you want to do? "
  read a
  if [ "$a" = "" -o "$a" = "q" ]; then
    exit 4
  fi
  if [ "$a" = "n" ]; then
    echo "Setting '$vf' to use version '$version'"
    echo $version > $vf
    echo "$vf changed - BUT NOT CHECKED INTO GIT"
    version=$v
    a=ok
  fi
  if [ "$a" = "u" ]; then
    echo "Using version '$v', but no change was made to '$vf'"
    a=ok
  fi
  if [ "$a" != 'ok' ]; then
    echo "Say what?  Don't know what '$a' is about. Stopping"
    exit 5
  fi
fi

#----------------------------------------------------------------
#   Begin build of package
#----------------------------------------------------------------
for f in $tempfiles; do         # Create files for this package
  cp debian/$f.$debpkg debian/$f || exit 1
done

#   If user provided PFX of place to install, use that, else set my own default
#   This path should not begin with /  If so, fix it
#
if [ "$PFX" = "" ]; then
  export PFX=usr/local/gotcloud
else
  firstc=`echo $PFX | cut -c 1-1`
  if [ "$firstc" = "/" ]; then
    export PFX=`echo $PFX | cut -c 2-`
  fi
fi

#   Specify version for this file.  Must specify -replace to overwrite deb file
#   This is to hassle the user to always keep version correct
pkg=`grep Package: debian/control | sed -e 's/Package: //'`
f=`ls $medir/../${pkg}_${version}*.deb 2>/dev/null`
if [ "$f" != "" -a "$replace" != 'y' ]; then
  echo "Package file '$f' exists for version '$version'. Specify -replace or set the version correctly"
  exit 2
fi
export PACKVER=$version

#   Build package
#   Supress errors, usually warnings about duplicates, until I can figure out what's going on
efile=/tmp/errs
dpkg-buildpackage -b -us -uc -rfakeroot 2> $efile
if [ "$?" != "0" ]; then
  a=`grep 'not including any source code' $efile`
  if [ "$a" = "" ]; then
    echo "=================== FAILED to build package ==================="
    cat $efile
    exit 2
  fi
fi
rm -f ../${pkg}*.changes debian/files 
for f in $tempfiles; do         # Remove files we created above
  rm -f debian/$f
done

echo "Package file now in `pwd`"
ls -la ${pkg}*.deb || (cat $efile; exit 1)
rm -f $efile

#----------------------------------------------------------------
#   Create RPM here
#----------------------------------------------------------------
if [ "$RPMDIR" != "" ]; then
  echo ""
  echo "Converting DEB into RPM"
  alien --to-rpm --scripts ${pkg}*.deb
  ls -la ${pkg}*.rpm
fi
exit;

