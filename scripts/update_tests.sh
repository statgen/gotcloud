#!/bin/bash
set -euo pipefail # Safety first!

# Find relevant directories
# =========================
gotcloud_root="$(dirname "$(dirname "$(readlink -e "$0")")")"
gotcloud_root="${gotcloud_root%/}" # Remove trailing slash
echo "gotcloud_root: $gotcloud_root/"
samtools="$gotcloud_root/bin/samtools"
tabix="$gotcloud_root/bin/tabix"
bgzip="$gotcloud_root/bin/bgzip"

set +u
[[ -z "$1" ]] && echo You must supply a directory of test results, gotten from \`gotcloud test\`. && exit 1
set -u

outdir="$1"
outdir="${outdir%/}"
echo "outdir: $outdir/"


# Copy umake results
# ============
cd "$gotcloud_root/test/umake/expected/"

# Copy umaketest
rm -r beagletest thundertest split4test beagle4test umaketest
mkdir beagletest thundertest split4test beagle4test
cp -r "$outdir/umaketest/umaketest" ./

# Move some directories from umaketest to their proper directories
mv umaketest/{beagle,umake_test.beagle.{conf,Makefile}} beagletest/
mkdir -p beagletest/thunder/chr20/ALL/ # `thunder/` must exist in both beagletest and thundertest, because thunder modifies that directory.
mv umaketest/thunder/chr20/ALL/split beagletest/thunder/chr20/ALL/
mv umaketest/{thunder,umake_test.thunder.{conf,Makefile}} thundertest/
mv umaketest/{split4,umake_test.split4.{conf,Makefile}} split4test/
mv umaketest/{beagle4,umake_test.beagle4.{conf,Makefile}} beagle4test/

# Add symlinks to predecessors
ln -s  ../umaketest/{vcfs,target,split,pvcfs,glfs,cpt,umake_test.snpcall.{Makefile,conf}} beagletest/
ln -s ../beagletest/{vcfs,target,split,pvcfs,glfs,cpt,beagle,umake_test.{snpcall,beagle}.{Makefile,conf}} thundertest/
ln -s  ../umaketest/{vcfs,target,split,pvcfs,glfs,cpt,umake_test.snpcall.{Makefile,conf}} split4test/
ln -s ../split4test/{vcfs,target,split,pvcfs,glfs,cpt,split4,umake_test.{snpcall,split4}.{Makefile,conf}} beagle4test/

# Clean up umaketest
rmdir umaketest/jobfiles

# Clean up beagletest
rm beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz{,.tbi}
ln -s chr20.filtered.PASS.beagled.vcf.gz beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz
ln -s chr20.filtered.PASS.beagled.vcf.gz.tbi beagletest/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz.tbi

# Clean up thundertest
ln -s ../../../../beagletest/thunder/chr20/ALL/split/ thundertest/thunder/chr20/ALL/split

# Clean up split4test
rm split4test/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz
ln -s ../../split/chr20/chr20.filtered.PASS.split.1.vcf.gz split4test/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz

# Delete some logfiles
for cmd in snpcall beagle thunder split4 beagle4; do
    rm umaketest/umake_test.$cmd.Makefile.cluster
    rm umaketest/umake_test.$cmd.Makefile.log
done


# Copy indel results
# ==================
cd "$gotcloud_root/test/indel"
rm -r expected
mkdir expected
cp -r "$outdir"/indel/indeltest/{indel,gotcloud.indel.Makefile} expected/


# Copy align results
# ==================
cd "$gotcloud_root/test/align/expected/"
rm -r aligntest
cp -r "$outdir/align/aligntest" .

rm aligntest/Makefiles/align{All,_Sample{1,2,3}}.Makefile.log
for qemp_file in aligntest/bams/*.qemp; do
    sort -o "$qemp_file" "$qemp_file"
done


# Copy bamQC results
# ==================
cd "$gotcloud_root/test/bamQC/expected/"
rm -r QCFiles
cp -r "$outdir/bamQC/bamQCtest/QCFiles" .
cp "$outdir"/bamQC/bamQCtest/gotcloud.bamQC.Makefile .

cd QCFiles
# Use ls instead of find to avoid "./" in $filename
for filename in *.genoCheck.depth* *.genoCheck.self* *.qplot.stats; do
    linkname="../../../align/expected/aligntest/QCFiles/${filename//SampleID/Sample}"
    # TODO do this after removing run-specific information
    if ! diff -I .recal.bam "$filename" "$linkname" > /dev/null; then
        echo; echo "In $PWD, $filename and $linkname are different, even ignoring lines with .recal.bam"
        echo "So, we're giving up."
        exit 86
    fi
    rm "$filename"
    ln -s "$linkname" "$filename"
done


# Copy recabQC results
# ====================
cd "$gotcloud_root/test/recabQC/expected/"
rm -r recab
cp -r "$outdir/recabQC/recabQCtest/recab" .
cp "$outdir/recabQC/recabQCtest/gotcloud.recabQC.Makefile" .

cd recab/
for qemp_file in *.qemp; do
    sort -o "$qemp_file" "$qemp_file"
done
for filename in SampleID*.recal.bam{,.OK,.bai,.bai.OK,.metrics,.qemp}; do
    linkname="../../../align/expected/aligntest/bams/${filename//SampleID/Sample}"
    linkname="${linkname/.OK/.done}"
    # TODO do this after removing run-specific information
    if ! (echo "$filename" | grep -q 'bam\(.bai\)\?$' || diff -I .recal.bam "$filename" "$linkname" > /dev/null ); then
        echo; echo "In $PWD, $filename and $linkname are different, even ignoring lines with .recal.bam"
        echo "So, we're giving up."
        exit 87
    fi
    rm "$filename"
    ln -s "$linkname" "$filename"
done

cd QCFiles/
# TODO link *.qplot.{stats,R}
for filename in *.genoCheck.depth* *.genoCheck.self*; do
    linkname="../../../../align/expected/aligntest/QCFiles/${filename//SampleID/Sample}"
    # TODO do this after removing run-specific information
    if ! diff -I .recal.bam "$filename" "$linkname" > /dev/null; then
        echo; echo "In $PWD, $filename and $linkname are different, even ignoring lines with .recal.bam"
        echo "So, we're giving up."
        exit 88
    fi
    rm "$filename"
    ln -s "$linkname" "$filename"
done


# Remove run-specific information
# ===============================
cd "$gotcloud_root/test"
sponge_write() { tmp="$(mktemp)"; cat > "$tmp"; mv "$tmp" "$1"; }

find . -type f | while read -r filename; do
    sed -i -e 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+\(/umaketest/umaketest\|/umaketest\|/indel/indeltest\|/indel\|/align/aligntest\|/align\)\?#<outdir_path>#g' \
        -e "s#${gotcloud_root}#<gotcloud_root>#g" "$filename"
done
find umake/expected/umaketest/ bamQC/expected/ recabQC/expected/ -type f | while read -r filename; do
    sed -i -e 's#^Analysis \([a-z]\+\) on [a-zA-Z ]\{7\} [0-9: ]\{16\}$#Analysis \1 on <date>#g' \
        -e 's_^##filedate=[0-9]\{8\}$_##filedate=<date>_' "$filename"
done
find umake/expected/beagle{4,}test/ indel/expected/ -type f | while read -r filename; do
    sed -i -e 's_^\(.*[Tt]ime.*:\s\+\).\{5,30\}$_\1<time>_' \
        -e 's_java -Xmx[0-9]\+m _java -Xmx<number>m _' "$filename"
done
# Note: indel/expected/indel/mergedBams/*bam and indel/expected/indel/final/*gz will break if re-encoded
find umake/expected/ indel/expected/ -name '*.gz' -type f | while read -r filename; do # avoid symlinks
    zcat "$filename" |
    sed -e 's_^##filedate=[0-9]\{8\}$_##filedate=<date>_' \
        -e 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+\(/umaketest\|/indel/indeltest\|/indel\)#<outdir_path>#g' |
    "$bgzip" | sponge_write "$filename"
    # Re-index where necessary
    if [[ -e "$filename.tbi" ]]; then
        rm "$filename.tbi"
        "$tabix" "$filename"
    fi
done
find align/expected/ indel/expected/indel/{aux,final,indelvcf} recabQC/expected/ -name '*.bam' -type f | while read -r filename; do
    tmp="$(mktemp)"
    "$samtools" view -h "$filename" |
    sed -e 's#/tmp/gotcloud-tests-[-a-zA-Z0-9]\+\(/umaketest/umaketest\|/umaketest\|/indel/indeltest\|/indel\|/align/aligntest\|/align\)\?#<outdir_path>#g' \
        -e "s#${gotcloud_root}#<gotcloud_root>#g" |
    "$samtools" view -b - | sponge_write "$filename"
    # Re-index
    if [[ -e "$filename.bai" ]]; then
        rm "$filename.bai"
        "$samtools" index "$filename"
    fi
done
echo FINISHED
