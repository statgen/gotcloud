#!/bin/bash
set -euo pipefail # Safety first!

# Find relevant directories
# =========================
gotcloud_root=$(dirname $(dirname $(readlink -e $0)))
gotcloud_root=${gotcloud_root%/} # Remove trailing slash
echo gotcloud_root: $gotcloud_root/

cd $gotcloud_root/test/umake/expected/
echo expected: $PWD/

outdir=$1
outdir=${outdir%/}
echo outdir: $outdir/

read -p "Press any key to continue."


# Copy results
# ============
rm -r umaketest
cp -r $outdir/snpcall/umaketest ./
rm umaketest/umake_test.snpcall.Makefile.log
rm umaketest/umake_test.snpcall.Makefile.cluster
rmdir umaketest/jobfiles

rm -r beagletest/{beagle,thunder,umake_test.beagle.{conf,Makefile}}
cp -r $outdir/beagle/umaketest/{beagle,thunder,umake_test.beagle.{conf,Makefile}} beagletest/
rm beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz
ln -s chr20.filtered.PASS.beagled.vcf.gz beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz
rm beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz.tbi
ln -s chr20.filtered.PASS.beagled.vcf.gz.tbi beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz.tbi

rm -r thundertest/{thunder,umake_test.thunder.{conf,Makefile}}
cp -r $outdir/thunder/umaketest/{thunder,umake_test.thunder.{conf,Makefile}} thundertest/
rm -r thundertest/thunder/chr20/ALL/split
ln -s ../../../../beagletest/thunder/chr20/ALL/split/ thundertest/thunder/chr20/ALL/split

rm -r split4test/{split4,umake_test.split4.{conf,Makefile}}
cp -r $outdir/split4/umaketest/{split4,umake_test.split4.{conf,Makefile}} split4test/
rm split4test/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz
ln -s ../../split/chr20/chr20.filtered.PASS.split.1.vcf.gz split4test/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz

rm -rf beagle4test/{beagle4,umake_test.beagle4.{conf,Makefile}}
cp -r $outdir/beagle4/umaketest/{beagle4,umake_test.beagle4.{conf,Makefile}} beagle4test/


# Clean up output
# ===============
sponge_write() { tmp=$(mktemp); cat > $tmp; mv $tmp $1; }

find . -type f | while read filename; do
    sed -i -e 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+/workdir/umaketest#<outdir_path>#g' \
        -e 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+/workdir#<outdir_path>#g' \
        -e "s#${gotcloud_root}#<gotcloud_root>#g" $filename
done
find umaketest -type f | while read filename; do
    sed -i -e 's#^Analysis \([a-z]\+\) on [a-zA-Z ]\{7\} [0-9: ]\{16\}$#Analysis \1 on <date>#g' \
        -e 's_^##filedate=[0-9]\{8\}$_##filedate=<date>_' $filename
done
find beagletest beagle4test -type f | while read filename; do
    sed -i 's_^\(.*[Tt]ime.*:\s\+\).\{5,30\}$_\1<time>_' $filename
done
find . -name '*.gz' -type f | while read filename; do # avoid symlinks
    zcat $filename |
    sed 's_^##filedate=[0-9]\{8\}$_##filedate=<date>_' |
    sed 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+/workdir#<outdir_path>#g' |
    gzip -n | sponge_write $filename # `gzip -n` suppresses writing of the current time into the file
done

echo FINISHED
