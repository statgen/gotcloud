#!/bin/bash
set -e -u -o pipefail # Safety first!

gotcloud_root="$(dirname $(dirname $0))"

# `make` to be sure that everything is up to date.
(cd "$gotcloud_root/src" && make)
echo -e "DONE WITH MAKE\n\n"


gotcloud_executable="$gotcloud_root/gotcloud"
echo using $gotcloud_executable

outdir="$(mktemp -d --tmpdir gotcloud-tests-$USER-XXX)"
echo "outputting to $outdir"

child_pids=""

cmds1="align indel bamQC recabQC"
for cmd in $cmds1; do
    bash -c "$gotcloud_executable $cmd --test $outdir/$cmd &> $outdir/$cmd.output; echo \$? > $outdir/$cmd.return_status; echo \$(date) finished $cmd;" &
    child_pids+=" $!"
done

set +e

# Run snpcall, ldrefine, and beagle4.
# The name of the directory ends up in the output files, so it must always be the same while code is running.
$gotcloud_executable snpcall --test $outdir/umaketest &> $outdir/snpcall.output
echo $? > $outdir/snpcall.return_status
echo $(date) finished snpcall
mv $outdir/umaketest $outdir/snpcall # Store the finished snpcall data away from the working path

cp -r $outdir/snpcall $outdir/umaketest
$gotcloud_executable ldrefine --test $outdir/umaketest &> $outdir/ldrefine.output
echo $? > $outdir/ldrefine.return_status
echo $(date) finished ldrefine
mv $outdir/umaketest $outdir/ldrefine

cp -r $outdir/snpcall $outdir/umaketest
$gotcloud_executable beagle4 --test $outdir/umaketest &> $outdir/beagle4.output
echo $? > $outdir/beagle4.return_status
echo $(date) finished beagle4
mv $outdir/umaketest $outdir/beagle4

set -e

for child_pid in $child_pids; do
    wait $child_pid
done

for cmd in $cmds1 snpcall ldrefine beagle4; do
    printf "%-10s %4d\n" $cmd $(cat $outdir/$cmd.return_status)
done

read -p "Delete $outdir? [y/n]" answer
if [[ "$answer" == y ]]; then
    rm -r "$outdir"
fi
