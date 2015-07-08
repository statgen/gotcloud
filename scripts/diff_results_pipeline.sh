#!/bin/bash
#
#   diff_results_pipeline.sh
#
# PIPE_NAME should be substituted by the name of the pipe.
#   Helper script for gotcloud pipeline --name PIPE_NAME --test 
#   After the test case is run, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_pipeline.sh ~/outtest /gotcloud/test/PIPE_NAME/expected PIPE_NAME
#
medir=`dirname $0`
if [ "$3" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir PIPE_NAME"
  exit 3
fi

BAM_UTIL=$medir/../bin/bam

RESULTS_DIR=$1
EXPECTED_DIR=$2
PIPE_NAME=$3
DIFF_FILE=diff_logfiles_results.txt
DIFFRESULTS=$RESULTS_DIR/$DIFF_FILE

BAMS=`find -L $EXPECTED_DIR/ -name "*bam"`
BAIS=`find -L $EXPECTED_DIR/ -name "*bai"`
QEMPS=`find -L $EXPECTED_DIR/ -name "*qemp"`

BAM_UTIL=$medir/../bin/bam

echo "Results from DIFF will be in $DIFFRESULTS"

SKIP_FILES="-x gotcloud.$PIPE_NAME.conf"
SKIP_FILES+=" -x gotcloud.$PIPE_NAME.Makefile"
SKIP_FILES+=" -x gotcloud.$PIPE_NAME.Makefile.log"
SKIP_FILES+=" -x $DIFF_FILE"
SKIP_FILES+=" -x jobfiles"
for file in $BAIS $QEMPS $BAMS
do
  SKIP_FILES+=" -x $(basename $file)"
done

diff -r $SKIP_FILES $RESULTS_DIR $EXPECTED_DIR \
    -I "^Analysis completed on " \
    -I "^Analysis finished on " \
    -I "^Analysis started on " \
    -I '^\s*Input Files : --vcf \[[^[:space:]]*\.vcf[^[:space:]]*\],$' \
    -I '^\s*--bam \[[^[:space:]]*\.bam\],$' \
    -I '^\s*Output options : --out \[[^[:space:]]*\.genoCheck\],$' \
    -I '^Opening BAM file [^[:space:]]*\.bam$' \
    -I '^Opening VCF file [^[:space:]]*\.vcf[^[:space:]]*$' \
    -I '^Reading BAM file [^[:space:]]*\.bam$' \
    -I '^Finished Reading BAM file [^[:space:]]*\.bam and VCF file [^[:space:]]*\.vcf[^[:space:]]*$' \
    -I '^Finished Reading BAM file [^[:space:]]*\.bam and VCF file [^[:space:]]*\.vcf[^[:space:]]*$' \
    -I '^[^[:space:]]*\.recal\.bam$'  \
    -I '^Processing BAM/SAM file [^[:space:]]*\.bam\.\.\.$'  \
    -I '^Stats\\BAM.*\.recal\.bam$'  \
    -I '^Reference genome file \[ [^[:space:]]*\.fa[^[:space:]]* \] is used.$' \
    -I '^GC content file \[ [^[:space:]]*\.gc \] is used for window size [0-9]*.$' \
    -I '^pdf(file="[^[:space:]]*QCFiles/SampleID[1-3].qplot.pdf", height=12, width=12);$' \
    -I '^\s*References : --reference \[[^[:space:]]*\.fa[^[:space:]]*\],$' \
    -I '^\s*--dbsnp \[[^[:space:]]*\.vcf[^[:space:]]*\]$' \
    -I '^\s*--stats \[[^[:space:]]*\.qplot\.stats\],$' \
    -I '^\s*--Rcode \[[^[:space:]]*\.qplot\.R\],$' \
    -I '^Writing recalibration table [^[:space:]]*bam\.qemp$' \
    -I '^Writing [^[:space:]]*recal\.bam$' \
    -I '^Input list file : [^[:space:],]*\.bam(, [^[:space:],]*\.bam)*$' \
    -I '^Input list file : [^[:space:]]*\.bam, [^[:space:]]*\.bam$' \
    -I '^Output BAM file : [^[:space:]]*\.bam$' \
    -I '^Output log file : [^[:space:]]*\.bam\.log$' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    status=2
fi

SED_REGEX="s/\S*recabQCtest\///g;s/\S*test\/recabQC\/bams\//test\/recabQC\/bams\//g;s/\S*test\/align\/expected\/aligntest\/bams\//test\/align\/expected\/aligntest\/bams\//g;s/'\S*bin\/qplot/'bin\/qplot/g;s/'\S*bin\/verifyBamID/'bin\/verifyBamID/g;s/\S*QCFiles/QCFiles/g;s/\S*mergedBams/mergedBams/g;s/\S*indelvcf/indelvcf/g;s/\S*aux/aux/g;s/\S*final/final/g;s/\S*scripts\/runcluster\.pl/scripts\/runcluster\.pl/g;s/-bashdir \S*\/jobfiles/-bashdir jobfiles/g;s/'\S*bin\/bam/'bin\/bam/g;s/'\S*bin\/samtools/'bin\/samtools/g;s/'\S*vt/'vt/g;s/| \S*vt/| vt/g;s/\S*test\/umake/test\/umake/g;s/\S*test\/chr20Ref/test\/chr20Ref/g"

diff <(sed "$SED_REGEX" $RESULTS_DIR/gotcloud.$PIPE_NAME.Makefile) <(sed "$SED_REGEX" $EXPECTED_DIR/gotcloud.$PIPE_NAME.Makefile) \
    >> $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed Makefile results validation. See mismatches in $DIFFRESULTS"
    status=3
fi

for expbam in $BAMS; do
    resbam=${expbam/$EXPECTED_DIR/$RESULTS_DIR}

    $BAM_UTIL diff --all --in1 $resbam --in2 $expbam >> $DIFFRESULTS
    if [ `wc -l $DIFFRESULTS|cut -f 1 -d ' '` != "0" ]; then
      echo "$resbam does not match $expbam. See mismatches in $DIFFRESULTS"
      exit 2
    fi
done
for expbai in $BAIS; do
    resbai=${expbai/$EXPECTED_DIR/$RESULTS_DIR}
    if [ ! -f $resbai ]; then
        echo "ERROR, Missing: $resbai"
        exit 3
    fi
done
for expfile in $QEMPS; do
    resfile=${expfile/$EXPECTED_DIR/$RESULTS_DIR}
    diff <(sort $resfile) <(sort $expfile) >> $DIFFRESULTS
    if [ "$?" != "0" ]; then
        echo "$resfile does not match $expfile. See mismatches in $DIFFRESULTS"
        exit 2
    fi
done

exit $status

