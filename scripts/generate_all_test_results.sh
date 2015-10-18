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

# Note: ldrefine is beagle + thunder, and beagle4 is `umake --split4` + `umake --beagle4`

# Note: all tests are run in `workdir`, because the name of the working directory must stay consistent through the whole process.

# run snpcall
$gotcloud_executable snpcall --test $outdir/workdir &> $outdir/snpcall.output
echo $? > $outdir/snpcall.return_status
echo $(date) finished snpcall
cp -r $outdir/workdir $outdir/snpcall # Store the finished snpcall data away from the working path

# run ldrefine, broken out into beagle + thunder (as in gotcloud)
# beagle
$gotcloud_root/bin/umake.pl --beagle --test $outdir/workdir &> $outdir/beagle.output
echo $? > $outdir/beagle.return_status
echo $(date) finished beagle
cp -r $outdir/workdir $outdir/beagle

# thunder
$gotcloud_root/bin/umake.pl --thunder --test $outdir/workdir &> $outdir/thunder.output
echo $? > $outdir/thunder.return_status
echo $(date) finished thunder
mv $outdir/workdir $outdir/thunder

# run beagle4, broken out into `umake.pl --split4` + `umake.pl --beagle4` (as in gotcloud)
# split4
cp -r $outdir/snpcall $outdir/workdir
$gotcloud_root/bin/umake.pl --split4 --test $outdir/workdir &> $outdir/split4.output
echo $? > $outdir/split4.return_status
echo $(date) finished split4
cp -r $outdir/workdir $outdir/split4

# beagle4
$gotcloud_root/bin/umake.pl --beagle4 --test $outdir/workdir &> $outdir/beagle4.output
echo $? > $outdir/beagle4.return_status
echo $(date) finished beagle4
mv $outdir/workdir $outdir/beagle4


set -e

for child_pid in $child_pids; do
    wait $child_pid
done

for cmd in $cmds1 snpcall beagle thunder split4 beagle4; do
    printf "%-10s %4d\n" $cmd $(cat $outdir/$cmd.return_status)
done

read -p "Delete $outdir? [y/n]" answer
if [[ "$answer" == y ]]; then
    rm -r "$outdir"
fi
