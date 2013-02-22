#!/bin/bash
#
#   diff_results.sh
#
#   Helper script for  gen_biopipeline.pl --test
#   After gen_biopipeline.pl runs the test case, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results.sh ~/outtest /gotcloud/test/align/expected
#
medir=`dirname $0`
if [ "$2" = "" ]; then
  echo "$0 failed"
  echo "Syntax:  $0 results_dir expected_dir"
  exit 3
fi
RESULTS_DIR=$1
EXPECTED_DIR=$2
DIFFRESULTS=$RESULTS_DIR/diff_logfiles_results.txt

BAM_UTIL=$medir/../bin/bam
BAM1_1_FILE=Sample1.recal.bam
BAM1_1=biopipetest/alignment.recal/$BAM1_1_FILE
BAM1_2_FILE=Sample1.merged.bam
BAM1_2=biopipetest/tmp/alignment.pol/$BAM1_2_FILE
BAM2_1_FILE=Sample2.recal.bam
BAM2_1=biopipetest/alignment.recal/$BAM2_1_FILE
BAM2_2_FILE=Sample2.merged.bam
BAM2_2=biopipetest/tmp/alignment.pol/$BAM2_2_FILE

BAI1=Sample1.recal.bam.bai
BAI2=Sample2.recal.bam.bai

MAKEFILE1=biopipe_Sample1.Makefile
MAKEFILE2=biopipe_Sample2.Makefile

# qemp files may be in varying order based on the system
QEMPS="Sample1.recal.bam.qemp Sample2.recal.bam.qemp"
SKIP_QEMPS="-x Sample1.recal.bam.qemp -x Sample2.recal.bam.qemp"
QEMP_SUBDIR=biopipetest/tmp/alignment.recal

#   Diff the results
#set -e                          # Fail on errors
echo "Results from DIFF will be in $DIFFRESULTS"
diff -r $RESULTS_DIR/biopipetest/ $EXPECTED_DIR/biopipetest/ -x $BAI1 -x $BAI2 \
    -x $BAM1_1_FILE -x $BAM1_2_FILE -x $BAM2_1_FILE -x $BAM2_2_FILE $SKIP_QEMPS \
    -x $MAKEFILE1 -x $MAKEFILE2 -x $MAKEFILE1.log -x $MAKEFILE2.log \
    -I '--in \[.*biopipetest/tmp/alignment.bwa/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$' \
    -I '--out \[.*biopipetest/tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$' \
    -I '--log \[.*biopipetest/tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam.log\]$' \
    -I '--fasta \[.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '--UR \[file:.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '# Started on:' \
    -I ' net.sf.picard.sam.MarkDuplicates INPUT=' \
    -I 'Stats\\BAM.*/biopipetest/alignment.recal/Sample[1-2].recal.bam.*/biopipetest/tmp/alignment.dedup/Sample[1-2].dedup.bam' \
    -I '-i (--in) = \[.*biopipetest/alignment.recal/Sample[1-2].recal.bam\]$' \
    -I '-r (--reference) = \[.*\]$' \
    -I '-b (--bfile) = \[.*hapmap_3.3.b37.chr20\]$' \
    -I '-o (--out) = \[.*/biopipetest/QCFiles/Sample[1-2].genoCheck\]$' \
    -I '^Writing output file .*/biopipetest/QCFiles/Sample[1-2].genoCheck$' \
    -I '^Finished writing output files .*/biopipetest/QCFiles/Sample[1-2].genoCheck.{bestRG,selfRG,bestSM,selfSM}$' \
    -I '^[0-9a-g]\{32\}  .*/biopipetest/alignment.recal/Sample[1-2].recal.bam$' \
    -I '^Reading the reference file ' \
    -I '^Finished reading the reference file ' \
    -I '^.*FamFile .*hapmap_3.3.b37.chr20.fam$' \
    -I '^.*BimFile .*hapmap_3.3.b37.chr20.bim$' \
    -I '^.*BedFile .*hapmap_3.3.b37.chr20.bed$' \
    -I '^Reading .*hapmap_3.3.b37.chr20.fam$' \
    -I '^Finished Reading .*hapmap_3.3.b37.chr20.fam containing 1397 individuals.* info$' \
    -I '^Reading .*/hapmap_3.3.b37.chr20.bim$' \
    -I '^Finished Reading .*/hapmap_3.3.b37.chr20.bim containing 37152 markers.* info$' \
    -I '^Opening .*/hapmap_3.3.b37.chr20.bed and checking the magic numbers$' \
    -I '^Writing recalibration table .*' \
    -I '^Writing recalibrated file .*' \
    -I 'Start: ' \
    -I 'Start iterating SAM/BAM file .*' \
    -I 'End: .*' \
    -I '^Input list file : ' \
    -I '^Output BAM file : ' \
    -I '^Output log file : ' \
    -I '^Writing .*biopipetest/tmp/alignment.dedup/Sample[1-2].dedup.bam$' \
    -I '^\[bwa_sai2sam_pe_core\] time elapses: ' \
    -I '^\[bwa_sai2sam_pe_core\] refine gapped alignments\.\.\. ' \
    -I '^\[bwa_sai2sam_pe_core\] print alignments\.\.\. ' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    exit 2
fi

# Check the Makefiles
diff -r $RESULTS_DIR/biopipetest/Makefiles/ $EXPECTED_DIR/biopipetest/Makefiles/ \
    -x "*.log" \
    -I '$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) .*fastq/Sample_[1-2]/File[1-2]_R[1-2].fastq.gz -f $(basename $@)' \
    -I '($(BWA_EXE) sampe -r .* $(FA_REF) $(basename $^) .*fastq/Sample_[1-2]/File[1-2]_R1.fastq.gz .*fastq/Sample_[1-2]/File[1-2]_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log' \
    -I '^[A-Z_][A-Z_]* = ' >> $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed Makefile results validation. See mismatches in $DIFFRESULTS"
    exit 2
fi


for file in $QEMPS; do
    sort $RESULTS_DIR/$QEMP_SUBDIR/$file | diff - $EXPECTED_DIR/$QEMP_SUBDIR/$file >> $DIFFRESULTS
    if [ "$?" != "0" ]; then
        echo "$RESULTS_DIR/$QEMP_SUBDIR/$file does not match $EXPECTED_DIR/$QEMP_SUBDIR/$file. See mismatches in $DIFFRESULTS"
        exit 2
    fi
done

if [ ! -f $RESULTS_DIR/biopipetest/alignment.recal/$BAI1 ]; then
    echo "ERROR, Missing: $RESULTS_DIR/biopipetest/alignment.recal/$BAI1"
    exit 3
fi
if [ ! -f $RESULTS_DIR/biopipetest/alignment.recal/$BAI2 ]; then
    echo "ERROR, Missing: $RESULTS_DIR/biopipetest/alignment.recal/$BAI2"
    exit 3
fi

set -e                          # Fail on errors
for file in $BAM1_1 $BAM1_2 $BAM2_1 $BAM2_2
do
  $BAM_UTIL diff --all --in1 $RESULTS_DIR/$file --in2 $EXPECTED_DIR/$file >> $DIFFRESULTS
  if [ `wc -l $DIFFRESULTS|cut -f 1 -d ' '` != "0" ]; then
      echo "$RESULTS_DIR/$file does not match $EXPECTED_DIR/$file. See mismatches in $DIFFRESULTS"
      exit 2
  fi
done

echo "Successful comparison of data in '$RESULTS_DIR' and '$EXPECTED_DIR'"
exit 0




