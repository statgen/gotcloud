#!/bin/bash
#
#   Create a Debian and TAR package
#
#   Debian dependencies:
#       debhelper
#       zlib1g-dev
#       libncurses5-dev
#
medir=`dirname $0`
sep="#############################################################"
cd $medir
cd ..                                   # I must be in debian parent directory
top=`pwd`

#----------------------------------------------------------------
#   Poor man's way to handle options
#----------------------------------------------------------------
replace=n
if [ "$1" = "-replace" ]; then
  replace=y
  shift
fi
clean=n
if [ "$1" = "-clean" ]; then
  clean=y
  shift
fi

#----------------------------------------------------------------
#   Figure out parameters
#----------------------------------------------------------------
debpkg=$1
version=$2
if [ "$#" -le "1" ]; then
  echo "Create a Debian and tar package file"
  echo ""
  echo "Syntax:   makedeb.sh  [options] package_name version"
  echo ""
  echo "Where options may be:"
  echo "   -replace   - Replace the package file. Must specify this first"
  echo "   -clean     - Force 'make clean' on src directory"
  echo ""
  echo "Where package_name may be:"
  echo "   bin        gotcloud-bin package"
  echo "   test       gotcloud-test package"
  echo ""
  echo "Where version may be:"
  echo "   =          Use default value in release_version.txt"
  echo "   M.n        New version"
  exit 1
fi

#   See if this is supposed to be a new version or what
vf=release_version.txt
v=`cat $vf`
if [ "$v" = "" ]; then
  echo "Version is not set in '$vf'.  Something is messed up"
  exit 3
fi
if [ "$version" = "=" ]; then       # If version is =, use what we have
  version=$v
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
tempfiles="changelog control postinst rules postrm "
for f in $tempfiles; do         # Create files for this package
  cp debian/$f.$debpkg debian/$f || exit 1
done

#   If user provided PFX of place to install, use that, else set my own default
#   This path should not begin with /  If so, fix it
if [ "$PFX" = "" ]; then
  export PFX=usr/local/gotcloud
else
  export PFX="${PFX#/}"
fi

#   Specify version for this file.  Must specify -replace to overwrite deb file
#   This is to hassle the user to always keep version correct
pkg=`grep Package: debian/control | sed -e 's/Package: //'`
f=`ls $top/${pkg}_${version}*.deb 2>/dev/null`
if [ "$f" != "" -a "$replace" != 'y' ]; then
  echo "Package file '$f' exists for version '$version'"
  echo "Specify -replace or set the version correctly"
  exit 2
fi
export PACKVER=$version                 # Needed by dpkg-buildpackage

#----------------------------------------------------------------
#   Build package files
#----------------------------------------------------------------
efile=/tmp/errs
touch $efile
#   Be sure binaries are ready.  Suppress make output unless error
if [ "$debpkg" = "bin" ]; then
  echo "Making binaries in src.  First time this will take a couple of minutes"
  cd src
  if [ "$clean" = "y" ]; then
    make clean > /dev/null 2> /dev/null
  fi
  make -j2 >> $efile 2>&1 || (cat $efile; exit 1)
  cd ..
  echo "Binaries created as necessary"
fi

if [ "$debpkg" = "test" ]; then
  /bin/echo -e "$sep\n#  Creating the 'test' package takes a pretty long time. Patience grasshopper...\n$sep"
fi

#   Supress errors, usually warnings about duplicates, until I can figure out what's going on
p=`which dpkg-buildpackage 2> /dev/null`
if [ "$p" = "" ]; then
  /bin/echo -e "$sep\n#   'dpkg-buildpackage' does not exist, no *.deb file will be created\n$sep"
  export DEB=no                         # Hack to avoid debian commands
  make -k -f debian/rules binary
else
  dpkg-buildpackage -b -us -uc -rfakeroot 2>> $efile
  if [ "$?" != "0" ]; then
    a=`grep 'not including any source code' $efile`
    if [ "$a" = "" ]; then
      echo "=================== FAILED to build package ==================="
      cat $efile
      exit 2
    fi
  fi
  echo "Debian package file created"
  ls -la $top/${pkg}*.deb || (cat $efile; exit 1)
fi

#   Build tar file
echo "Creating tar file for '$debpkg'"
tarpkg="${pkg}_$version"
cd debian/tmp/usr/local || exit 3
tar czf $top/$tarpkg.tar.gz gotcloud
cd $top || exit 4

#   Done creating packages, show what we made
echo "Tar file created"
ls -la $top/$tarpkg.tar.gz

#   Clean up and exit
rm -rf ../${pkg}*.changes debian/files debian/tmp $efile  /tmp/xxremove
for f in $tempfiles; do
  rm -f debian/$f
done
exit;

