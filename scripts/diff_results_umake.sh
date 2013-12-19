#!/bin/bash
#
#   diff_results_umake.sh
#
#   Helper script for  umake.pl --test
#   After umake.pl runs the test case, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_umake.sh ~/outtest gotcloud/test/umake/expected
medir=`dirname $0`
if [ "$2" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir"
  exit 3
fi
RESULTS_DIR=$1
EXPECTED_DIR=$2
DIFF_FILE=diff_logfiles_results_umake.txt
DIFFRESULTS=$RESULTS_DIR/$DIFF_FILE

if [ -d $RESULTS_DIR/umaketest ]; then
    RESULTS_DIR=$RESULTS_DIR/umaketest;
fi

if [ -d $EXPECTED_DIR/umaketest ]; then
    EXPECTED_DIR=$EXPECTED_DIR/umaketest;
fi


BAM_UTIL=$medir/../bin/bam

#VCF_GZS_WITH_DIR:=$(wildcard $(EXPECTED_DIR)/pvcfs/chr20/*/*.vcf.gz) $(wildcard $(EXPECTED_DIR)/vcfs/chr20/*.vcf.gz) $(wildcard $(EXPECTED_DIR)/split/chr20/*.vcf.gz)
#VCF_GZS_WITH_SUBDIR:=$(subst $(EXPECTED_DIR)/,,$(VCF_GZS_WITH_DIR))
#VCF_GZS:=$(notdir $(VCF_GZS_WITH_DIR))

EXPECTED_VCF_GZS=`find $EXPECTED_DIR/ -name "*vcf.gz"`
RESULTS_VCF_GZS=`find $RESULTS_DIR/ -name "*vcf.gz"`

SKIP_GZS=""
for file in $EXPECTED_VCF_GZS
do
  SKIP_GZS+="-x $(basename $file) "
done

#SKIP_GZS=""; for file in `ls $EXPECTED_DIR/pvcfs/chr20/*/*vcf.gz $EXPECTED_DIR/vcfs/chr20/*.vcf.gz $EXPECTED_DIR/split/chr20/*.vcf.gz`; do SKIP_GZS+="-x $(basename $file) "; done;
#echo $SKIP_GZS

TBI1=chr20.hardfiltered.vcf.gz.tbi
TBI2=chr20.filtered.vcf.gz.tbi

echo "Results from DIFF will be in $DIFFRESULTS"

diff -r $RESULTS_DIR $EXPECTED_DIR \
    $SKIP_GZS -x $TBI1 -x $TBI2 -x $DIFF_FILE -x umake_test.snpcall.conf -x umake_test.snpcall.Makefile.log\
    -I "^Analysis completed on " \
    -I "^Analysis finished on " \
    -I "^Analysis started on " \
    -I "^##filedate=" \
    -I '^Writing to VCF file .*vcfs/chr20/chr20.*filtered\.sites\.vcf$' \
    -I '^INDEL5 : INDEL >= 5 bp with .*chr20Ref/1kg\.pilot_release\.merged\.indels\.sites\.hg19\.chr20\.vcf$'\
    -I '^\s*Pedigree File : --ped \[.*glfs/samples/chr20/20000001.25000000/glfIndex\.ped\]$' \
    -I '^\s*Input Options : --anchor \[.*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.vcf\],$' \
    -I '^\s*--prefix \[.*pvcfs/chr20/20000001.25000000/\],$' \
    -I '^\s*--index \[.*umake_test\.index\]$' \
    -I '^\s*Output Options : --outvcf \[.*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.stats\.vcf\],$' \
    -I '^\s*Base Call File : .*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.vcf (-bname)$' \
    -I '^Opening /.*split/chr20/chr20.*filtered\.PASS\.split\.[1-6]\.vcf\.\.\.$' \
    -I '^[^[:space:]]*split/chr20/chr20.*filtered\.PASS\.split\.[1-6]\.vcf\.gz$' \
    -I '^[^[:space:]]*pvcfs/chr20/20000001.25000000/NA[0-9]*\.mapped.*\.bam\.20\.20000001.25000000\.vcf\.gz$' \
    -I '^[^[:space:]]*glfs/samples/chr20/20000001.25000000/NA[0-9]*\.20\.20000001.25000000\.glf$' \
    -I '^bam file\s* : .*bams/NA[0-9]*\.mapped.*\.bam$' \
    -I '^input VCF file\s*: .*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.sites\.vcf$' \
    -I '^bam index file\s*: .*bams/NA[0-9]*\.mapped.*\.bam\.bai$' \
    -I '^output VCF file\s*: .*pvcfs/chr20/20000001.25000000/NA[0-9]*\.mapped.*\.bam\.20\.20000001.25000000\.vcf\.gz (gzip)$' \
    -I '^NA[0-9]*\s*NA[0-9]*\s*0\s*0\s*2\s*.*glfs/samples/chr20/20000001.25000000/NA[0-9]*\.20\.20000001.25000000\.glf$' \
    -I '^OUT_DIR=.*$' \
    -I '^GOTCLOUD_ROOT=.*$' \
    -I '^Reading Input File .*chr20.filtered.sites.vcf.raw$' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    exit 2
fi


set -e                          # Fail on errors

for file in $EXPECTED_VCF_GZS
do
  if [ ! -f ${file/$EXPECTED_DIR/$RESULTS_DIR} ]
  then
      echo "ERROR: Missing ${file/$EXPECTED_DIR/$RESULTS_DIR}"
      exit 3
  fi
done

for file in $RESULTS_VCF_GZS
do
  if [ ! -f ${file/$RESULTS_DIR/$EXPECTED_DIR} ]
  then
      echo "ERROR: Unexpected file ${file/$RESULTS_DIR/$EXPECTED_DIR}"
      exit 3
  fi
done

for file in $VCF_GZS_WITH_SUBDIR; do
    zdiff -I "^##filedate=.*$" -I"^#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	.*$file$" $EXPECTED_DIR/$file $RESULTS_DIR/$file >> $DIFFRESULTS;
    if [ $? -ne 0 ] ; then
        echo "$file failed. See mismatches in $DIFFRESULTS"
        exit 2
    fi
done
	
if [ ! -f $RESULTS_DIR/vcfs/chr20/$TBI1 ]; then \
    echo "ERROR, Missing: $RESULTS_DIR/vcfs/chr20/$TBI1"
    exit 3
fi

if [ ! -f $EXPECTED_DIR/vcfs/chr20/$TBI1 ]; then \
    echo "ERROR, Missing: $EXPECTED_DIR/vcfs/chr20/$TBI1"
    exit 3
fi

if [ ! -f $RESULTS_DIR/vcfs/chr20/$TBI2 ]; then \
    echo "ERROR, Missing: $RESULTS_DIR/vcfs/chr20/$TBI2"
    exit 3
fi

if [ ! -f $EXPECTED_DIR/vcfs/chr20/$TBI2 ]; then \
    echo "ERROR, Missing: $EXPECTED_DIR/vcfs/chr20/$TBI2"
    exit 3
fi

echo "Successful comparison of data in '$RESULTS_DIR' and '$EXPECTED_DIR'"
exit 0
