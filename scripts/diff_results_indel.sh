#!/bin/bash
#
#   diff_results_indel.sh
#
#   Helper script for gotcloud indel --test
#   After the test case is run, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_indel.sh ~/outtest /gotcloud/test/indel/expected
#
medir=`dirname $0`
if [ "$2" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir"
  exit 3
fi
RESULTS_DIR=$1
EXPECTED_DIR=$2
DIFF_FILE=diff_logfiles_results.txt
DIFFRESULTS=$RESULTS_DIR/$DIFF_FILE

if [ -d $RESULTS_DIR/indeltest ]; then
    RESULTS_DIR=$RESULTS_DIR/indeltest;
fi

if [ -d $EXPECTED_DIR/indeltest ]; then
    EXPECTED_DIR=$EXPECTED_DIR/indeltest;
fi

DISCOVER_LIST=candidate_vcf_files.txt
GENOTYPE_LISTS=`find -L $EXPECTED_DIR/ -name "*.list.txt"`

SKIP_FILES="-x gotcloud.indel.conf -x gotcloud.indel.Makefile -x gotcloud.indel.Makefile.log -x "$DISCOVER_LIST
for file in $GENOTYPE_LISTS
do
  SKIP_FILES+=" -x $(basename $file)"
done

status=0

#   Diff the results
#set -e                          # Fail on errors
echo "Results from DIFF will be in $DIFFRESULTS"

diff -r $RESULTS_DIR/ $EXPECTED_DIR/ -x jobfiles -x $DIFF_FILE $SKIP_FILES \
    -I '^options: \[L\] input VCF file list *.*aux/candidate_vcf_files\.txt ([0-9]* files)$' \
    -I '^options: *input VCF file *.*aux/all\.sites\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*aux/all\.sites\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^options: *input VCF file *.*aux/all\.sites\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*aux/all\.sites\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*aux/probes\.sites\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*final/merge/all\.genotypes\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*final/merge/all\.genotypes\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^ *\[o\] output VCF file *.*indelvcf/\S*/\S*\.sites\.bcf$' \
    -I '^ *\[r\] reference FASTA [fF]ile *.*test/chr[0-9]*Ref/human_g1k_v37_chr[0-9]*\.fa$' \
    -I '^options: *\[b\] input BAM File *\S*\.bam$' \
    -I '^options: *\[b\] input BAM File *.*mergedBams/\S*\.bam$' \
    -I '^Options: *Input VCF File *.*aux/probes\.sites\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^ *Input BAM File *\S*\.bam$' \
    -I '^ *Input BAM File *.*mergedBams/\S*\.bam$' \
    -I '^ *Output VCF File *.*indelvcf/\S*/\S*\.genotypes\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^Input list file : \S*\.bam, \S*\.bam$' \
    -I '^ *Output BAM file : .*mergedBams/\S*\.bam$' \
    -I '^ *Output log file : .*mergedBams/\S*\.bam\.log$' \
    -I '^Time elapsed: .*$' \
    -I '^processing .*final/merge/all\.genotypes\.[0-9]*\.bcf$' \
    -I '^processing .*final/merge/all\.genotypes\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    -I '^processing .*/.*\.genotypes\.[0-9]*\.[0-9]*\.[0-9]*\.bcf$' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    status=2
fi


SED_REGEX="s/tmpNoLibCtrPltfm/tmp/g;s/tmpNoSM/tmp/g;s/tmpOrig/tmp/g;s/\S*mergedBams/mergedBams/g;s/\S*indelvcf/indelvcf/g;s/\S*aux/aux/g;s/\S*final/final/g;s/\S*scripts\/runcluster\.pl/scripts\/runcluster\.pl/g;s/-bashdir \S*\/jobfiles/-bashdir jobfiles/g;s/'\S*bin\/bam/'bin\/bam/g;s/'\S*bin\/samtools/'bin\/samtools/g;s/'\S*vt/'vt/g;s/| \S*vt/| vt/g;s/\S*test\/umake/test\/umake/g;s/\S*test\/chr20Ref/test\/chr20Ref/g"

diff <(sed "$SED_REGEX" $RESULTS_DIR/indel/aux/$DISCOVER_LIST) <(sed "$SED_REGEX" $EXPECTED_DIR/indel/aux/$DISCOVER_LIST) \
    >> $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation of $RESULTS_DIR/aux/$DISCOVER_LIST. See mismatches in $DIFFRESULTS"
    status=3
fi

for file in $GENOTYPE_LISTS
do
  diff <(sed "$SED_REGEX" ${file/$EXPECTED_DIR/$RESULTS_DIR}) <(sed "$SED_REGEX" $file) \
    >> $DIFFRESULTS
  if [ "$?" != "0" ]; then
      echo "Failed results validation of ${file/$EXPECTED_DIR/$RESULTS_DIR} & $file. See mismatches in $DIFFRESULTS"
      status=3
  fi
done

diff <(sed "$SED_REGEX" $RESULTS_DIR/gotcloud.indel.Makefile) <(sed "$SED_REGEX" $EXPECTED_DIR/gotcloud.indel.Makefile) \
    >> $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed Makefile results validation. See mismatches in $DIFFRESULTS"
    status=3
fi



if [ $status == 0 ]
then
    echo "Successful comparison of data in '$RESULTS_DIR' and '$EXPECTED_DIR'"
    exit 0
fi
exit $status



