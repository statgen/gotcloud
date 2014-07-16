#!/bin/bash
#
#   diff_results_umake.sh
#
#   Helper script for  umake.pl --test
#   After umake.pl runs the test case, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_umake.sh ~/outtest gotcloud/test/umake/expected snpcall
medir=`dirname $0`
if [ "$2" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir"
  exit 3
fi
RESULTS_DIR=$1
EXPECTED_DIR=$2
TYPE=$3
DIFF_FILE=diff_logfiles_results_$TYPE.txt
DIFFRESULTS=$RESULTS_DIR/$DIFF_FILE


if [ -d $RESULTS_DIR/umaketest ]; then
    RESULTS_DIR=$RESULTS_DIR/umaketest;
fi

DIR_EXCLUDE=
if [ "$TYPE" == "snpcall" ]; then
    EXPECTED_DIR=$EXPECTED_DIR/umaketest;
else
    EXPECTED_DIR=$EXPECTED_DIR/${TYPE}test;
    if [ "$TYPE" == "beagle" ]; then
        DIR_EXCLUDE="--exclude split4 --exclude beagle4 -x umake_test.beagle4.Makefile -x umake_test.split4.Makefile";
        FIND_EXCLUDE=(-not -path '*/split4/*' -not -path '*/beagle4/*');
    else 
        if [ "$TYPE" == "thunder" ]; then
            DIR_EXCLUDE="--exclude split4 --exclude beagle4 -x umake_test.beagle4.Makefile -x umake_test.split4.Makefile";
            FIND_EXCLUDE=(-not -path '*/split4/*' -not -path '*/beagle4/*');
        else
            if [ "$TYPE" == "split4" ]; then
                DIR_EXCLUDE="--exclude beagle --exclude thunder -x umake_test.beagle.Makefile -x umake_test.thunder.Makefile";
                FIND_EXCLUDE=(-not -path '*/thunder/*' -not -path '*/beagle/*');
            else
                if [ "$TYPE" == "beagle4" ]; then
                    DIR_EXCLUDE="--exclude beagle --exclude thunder -x umake_test.beagle.Makefile -x umake_test.thunder.Makefile";
                    FIND_EXCLUDE=(-not -path '*/thunder/*' -not -path '*/beagle/*');
                fi
            fi
        fi
    fi
fi


BAM_UTIL=$medir/../bin/bam
EXPECTED_VCF_GZS=$(find -L $EXPECTED_DIR/ -name "*vcf.gz" "${FIND_EXCLUDE[@]}")
RESULTS_VCF_GZS=`find $RESULTS_DIR/ -name "*vcf.gz" "${FIND_EXCLUDE[@]}"`
EXPECTED_TBIS=`find -L $EXPECTED_DIR/ -name "*tbi" "${FIND_EXCLUDE[@]}"`

SKIP_GZS=""
for file in $EXPECTED_VCF_GZS
do
  SKIP_GZS+="-x $(basename $file) "
done

SKIP_TBIS=""
for file in $EXPECTED_TBIS
do
  SKIP_TBIS+="-x $(basename $file) "
done

SKIP_LOGS=""
for file in umake_test.snpcall umake_test.beagle umake_test.thunder umake_test.split4 umake_test.beagle4
do
  SKIP_LOGS+="-x $file.conf -x $file.Makefile.log -x $file.Makefile.cluster "
done

#SKIP_GZS=""; for file in `ls $EXPECTED_DIR/pvcfs/chr20/*/*vcf.gz $EXPECTED_DIR/vcfs/chr20/*.vcf.gz $EXPECTED_DIR/split/chr20/*.vcf.gz`; do SKIP_GZS+="-x $(basename $file) "; done;
#echo $SKIP_GZS

status=0


echo "Results from DIFF will be in $DIFFRESULTS"

diff -r $RESULTS_DIR $EXPECTED_DIR \
    $SKIP_GZS $SKIP_TBIS -x $DIFF_FILE $SKIP_LOGS -x jobfiles $DIR_EXCLUDE\
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
    -I '^Opening /.*beagle/chr20/split/bgl\.1\.chr20\.PASS\.1\.vcf\.gz\.\.$' \
    -I '^Start time: ' \
    -I '^  like=/.*beagle/chr20/like/chr20\.PASS\.1\.gz$' \
    -I '^  out=/.*beagle/chr20/split/bgl\.1$' \
    -I '^Running time for phasing: [0-9]* seconds$' \
    -I '^/.*thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.gz$' \
    -I '^Opening /.*thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.\.\.$' \
    -I '^   Shotgun Sequences : --shotgun \[.*/thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.gz\],$' \
    -I '^        Output Files : --prefix \[.*/thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\],$' \
    -I '^Outputing VCF file [^[:space:]]*/thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\.vcf\.gz$' \
    -I '^Opening /[^[:space:]]*thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\.vcf\.gz\.\.$' \
    -I $'^1\t20\t20000121\t20299968\t[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I $'^*** Redundant: 2\t20\t20000121\t20299968\t[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.2.vcf.gz$' \
    -I '^all: [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I '^[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz: [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf$' \
    -I $'^\t[^[:space:]]*scripts/../bin/bgzip [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf$' \
    -I '^  gl=[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I '^  out=[^[:space:]]*beagle4/chr20/like/chr20.PASS.1$' \
    -I '^Time for building model:[[:space:]]*[0-9]* seconds$' \
    -I '^Time for sampling (singles):[[:space:]]*[0-9]* seconds$' \
    -I '^Total time for building model:[[:space:]]*[0-9]* seconds$' \
    -I '^Total time for sampling:[[:space:]]*[0-9]* seconds$' \
    -I '^Total run time:[[:space:]]*[0-9]* seconds$' \
    -I '^End time: ' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    status=2
fi

set -e                          # Fail on errors

for file in $EXPECTED_VCF_GZS
do
  if [ ! -f ${file/$EXPECTED_DIR/$RESULTS_DIR} ]
  then
      echo "ERROR: Missing ${file/$EXPECTED_DIR/$RESULTS_DIR}"
      status=3
  fi
done

for file in $RESULTS_VCF_GZS
do
  if [ ! -f ${file/$RESULTS_DIR/$EXPECTED_DIR} ]
  then
      echo "ERROR: Unexpected file ${file/$RESULTS_DIR/$EXPECTED_DIR}"
      status=3
  fi
done

set +e                          # Do not fail on errors
for file in $EXPECTED_VCF_GZS; do
    zdiff -I"^##filedate=.*$" -I"^#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	.*$" $file ${file/$EXPECTED_DIR/$RESULTS_DIR} >> $DIFFRESULTS;
    if [ $? -ne 0 ] ; then
        echo "$file failed. See mismatches in $DIFFRESULTS"
        status=2
    fi
done
	
set -e                          # Fail on errors
for file in $EXPECTED_TBIS; do
    if [ ! -f ${file/$EXPECTED_DIR/$RESULTS_DIR} ]; then \
        echo "ERROR, Missing: ${file/$EXPECTED_DIR/$RESULTS_DIR}"
        status=3
    fi
done

if [ $status == 0 ]
then
    echo "Successful comparison of data in '$RESULTS_DIR' and '$EXPECTED_DIR'"
    exit 0
fi
exit $status
