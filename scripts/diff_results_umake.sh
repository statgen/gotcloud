#!/bin/bash
#
#   diff_results_umake.sh
#
#   Helper script for  umake.pl --test
#   After umake.pl runs the test case, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_umake.sh ~/outtest gotcloud/test/umake/expected snpcall
set -e -u -o pipefail

medir=`dirname $0`
if [ "$2" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir snpcall|beagle|thunder|split4|beagle4"
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

FIND_EXCLUDE=()
DIR_EXCLUDE=
if [ "$TYPE" == "snpcall" ]; then
    if [ -d $EXPECTED_DIR/umaketest ]; then
        EXPECTED_DIR=$EXPECTED_DIR/umaketest;
    fi
else
    if [ -d $EXPECTED_DIR/${TYPE}test ]; then
        EXPECTED_DIR=$EXPECTED_DIR/${TYPE}test;
    fi
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
EXPECTED_GZS=$(find -L $EXPECTED_DIR/ -name "*.gz" "${FIND_EXCLUDE[@]:+${FIND_EXCLUDE[@]}}") # This is a `set -u`-compliant version of ${FIND_EXCLUDE[@]}
RESULTS_GZS=`find $RESULTS_DIR/ -name "*.gz" "${FIND_EXCLUDE[@]:+${FIND_EXCLUDE[@]}}"`
EXPECTED_TBIS=`find -L $EXPECTED_DIR/ -name "*tbi" "${FIND_EXCLUDE[@]:+${FIND_EXCLUDE[@]}}"`

SKIP_GZS=""
for file in $EXPECTED_GZS
do
  SKIP_GZS+="-x $(basename $file) "
done

SKIP_TBIS=""
for file in $EXPECTED_TBIS
do
  SKIP_TBIS+="-x $(basename $file) "
done

SKIP_LOGS=""
for file in umake_test.snpcall umake_test.beagle umake_test.thunder umake_test.split4 umake_test.beagle4 umake.snpcall umake.beagle umake.thunder umake.split4 umake.beagle4
do
  SKIP_LOGS+="-x $file.conf -x $file.Makefile.log -x $file.Makefile.cluster "
done

status=0


echo "Results from DIFF will be in $DIFFRESULTS"

#    -I '^.*vcfPileup.*$' \

set +e
diff -r $RESULTS_DIR $EXPECTED_DIR \
    $SKIP_GZS $SKIP_TBIS -x $DIFF_FILE $SKIP_LOGS -x jobfiles -x 20.20000001.25000000.txt $DIR_EXCLUDE\
    -I "^Analysis completed on " \
    -I "^Analysis finished on " \
    -I "^Analysis started on " \
    -I "^##filedate=" \
    -I '^Writing to VCF file .*vcfs/chr20/chr20.*filtered\.sites\.vcf$' \
    -I '^INDEL5 : INDEL >= 5 bp with .*chr20Ref/1kg\.pilot_release\.merged\.indels\.sites\.hg19\.chr20\.vcf$'\
    -I '^\s*Pedigree File : --ped \[.*vcfs/chr20/[0-9]*\.[0-9]*/glfIndex\.ped\]$' \
    -I '^\s*Input Options : --anchor \[.*vcfs/chr20/[0-9]*\.[0-9]*/chr20\.[0-9]*\.[0-9]*\.vcf\],$' \
    -I '^\s*--prefix \[.*pvcfs/chr20/[0-9]*\.[0-9]*/\],$' \
    -I '^\s*--list \[[^][:space:]]*\]$' \
    -I '^\s*Output Options : --outvcf \[.*vcfs/chr20/[0-9]*\.[0-9]*/chr20\.[0-9]*\.[0-9]*\.stats\.vcf\],$' \
    -I '^\s*Base Call File : .*vcfs/chr20/[0-9]*\.[0-9]*/chr20\.[0-9]*\.[0-9]*\.vcf (-bname)$' \
    -I '^Opening .*split/chr20/chr20.*filtered\.PASS\.split\.[1-6]\.vcf\.\.\.$' \
    -I '^[^[:space:]]*split/chr20/chr20.*filtered\.PASS\.split\.[1-6]\.vcf\.gz$' \
    -I '^[^[:space:]]*pvcfs/chr20/[0-9]*\.[0-9]*/[^/ \n\t]*\.bam\.20\.[0-9]*\.[0-9]*\.vcf\.gz$' \
    -I '^[^[:space:]]*pvcfs/chr20/[0-9]*\.[0-9]*/[^/ \n\t]*\.cram\.20\.[0-9]*\.[0-9]*\.vcf\.gz$' \
    -I '^[^[:space:]]*glfs/samples/chr20/[0-9]*\.[0-9]*/[^/ \n\t]*\.20\.[0-9]*\.[0-9]*\.glf$' \
    -I '^bam file\s* : .*bam$' \
    -I '^input VCF file\s*: .*vcfs/chr20/[0-9]*\.[0-9]*/chr20\.[0-9]*\.[0-9]*\.sites\.vcf$' \
    -I '^bam index file\s*: .*bams/[^/ \n\t]*\.bam\.bai$' \
    -I '^output VCF file\s*: .*pvcfs/chr20/[0-9]*.[0-9]*/[^/ \n\t]*\.bam\.20\.[0-9]*.[0-9]*\.vcf\.gz (gzip)$' \
    -I '^output VCF file\s*: .*pvcfs/chr20/[0-9]*.[0-9]*/[^/ \n\t]*\.cram\.20\.[0-9]*.[0-9]*\.vcf\.gz (gzip)$' \
    -I '^[^/ \n\t]*\s*[^/ \n\t]*\s*0\s*0\s*2\s*.*glfs/samples/chr20/[0-9]*\.[0-9]*/[^/ \n\t]*\.20\.[0-9]*\.[0-9]*\.glf$' \
    -I '^OUT_DIR=.*$' \
    -I '^GOTCLOUD_ROOT=.*$' \
    -I '^Reading Input File .*chr20.filtered.sites.vcf.raw$' \
    -I '^Reading Input File .*/vcfs/filtered.sites.vcf.raw$' \
    -I '^Opening .*beagle/chr20/split/bgl\.1\.chr20\.PASS\.1\.vcf\.gz\.\.$' \
    -I '^Start time: ' \
    -I '^  like=.*beagle/chr20/like/chr20\.PASS\.1\.gz$' \
    -I '^  out=.*beagle/chr20/split/bgl\.1$' \
    -I '^Running time for phasing: ' \
    -I 'thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.gz$' \
    -I '^Opening .*thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.\.\.$' \
    -I '^   Shotgun Sequences : --shotgun \[.*/thunder/chr20/ALL/split/chr20\.filtered\.PASS\.beagled\.ALL\.split\.1\.vcf\.gz\],$' \
    -I '^        Output Files : --prefix \[.*/thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\],$' \
    -I '^Outputing VCF file [^[:space:]]*/thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\.vcf\.gz$' \
    -I '^Opening [^[:space:]]*thunder/chr20/ALL/thunder/chr20\.filtered\.PASS\.beagled\.ALL\.thunder\.1\.vcf\.gz\.\.$' \
    -I '^1\s20\s20000121\s20299968\s[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I '^*** Redundant: 2\s20\s20001483\s20299968\s[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.2.vcf.gz$' \
    -I '^all: [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I '^[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz: [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf$' \
    -I '^\s[^[:space:]]*scripts/../bin/bgzip [^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf$' \
    -I '^  gl=[^[:space:]]*split4/chr20/chr20.filtered.PASS.split.1.vcf.gz$' \
    -I '^  out=[^[:space:]]*beagle4/chr20/like/chr20.PASS.1$' \
    -I '^Time for building model:' \
    -I '^Time for sampling (singles):' \
    -I '^Total time for building model:' \
    -I '^Total time for sampling:' \
    -I '^Total run time:' \
    -I '^Command line: java -Xmx[^\s]*m -jar beagle.jar$' \
    -I '^End time: ' \
    -I '^\s*Output : --outfile \[.*glfs/samples/chr20/[0-9]*\.[0-9]*/.*\.[0-9]*\.[0-9]*\.glf\],$' \
    -I '^  .*glfs/bams/.*/chr20/.*\.bam\.[0-9]*\.[0-9]*\.glf$' \
    -I '^  .*glfs/bams/.*/chr20/.*\.cram\.[0-9]*\.[0-9]*\.glf$' \
    -I '^.*/bin/invNorm --in .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.raw --out .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.norm$' \
    -I '^\s*Input options : --in \[.*vcfs/chr20/chr20\.filtered\.sites\.vcf\.raw\],$' \
    -I '^\s*Output Options : --out \[.*vcfs/chr20/chr20\.filtered\.sites\.vcf\.norm\],$' \
    -I '^Reading positive examples from .*chr20Ref/.*$' \
    -I '^.*/bin/svm-train -s 0 -t 2 .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.labeled\.svm .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.svm\.model$' \
    -I '^.*/bin/svm-predict .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.svm .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.svm\.model .*vcfs/chr20/chr20\.filtered\.sites\.vcf\.svm\.pred$' \
    -I '^\s*VCF Input options : --in-vcf \[.*vcfs/chr20/chr20\.merged\.stats\.vcf\]$' \
    -I '^\s*--indelVCF \[.*chr20Ref/1kg\.pilot_release\.merged\.indels\.sites\.hg19\.chr20\.vcf\],$' \
    -I '^\s*Output Options : --out \[.*vcfs/chr20/chr20\.hardfiltered\.sites\.vcf\],$' \
    -I '^loading .*chr20Ref/dbsnp135_chr20\.vcf\.gz as a VCF input\.\.$' \
    -I '^Warning: The index file is older than the data file:' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    status=2
fi

set -e                          # Fail on errors

for file in $EXPECTED_GZS
do
  if [ ! -f ${file/$EXPECTED_DIR/$RESULTS_DIR} ]
  then
      echo "ERROR: Missing ${file/$EXPECTED_DIR/$RESULTS_DIR}"
      status=3
  fi
done

for file in $RESULTS_GZS
do
  if [ ! -f ${file/$RESULTS_DIR/$EXPECTED_DIR} ]
  then
      echo "ERROR: Unexpected file ${file/$RESULTS_DIR/$EXPECTED_DIR}"
      status=3
  fi
done

set +e                          # Do not fail on errors
for file in $EXPECTED_GZS; do
    zdiff -I"^##filedate=" -I"^#CHROM\sPOS\sID\sREF\sALT\sQUAL\sFILTER\sINFO\sFORMAT" $file ${file/$EXPECTED_DIR/$RESULTS_DIR} >> $DIFFRESULTS;
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
