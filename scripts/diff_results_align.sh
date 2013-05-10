#!/bin/bash
#
#   diff_results_align.sh
#
#   Helper script for  align.pl --test
#   After align.pl runs the test case, this is called
#   to verify the output results. Typically called like this:
#
#       diff_results_align.sh ~/outtest /gotcloud/test/align/expected
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

if [ -d $RESULTS_DIR/aligntest ]; then
    RESULTS_DIR=$RESULTS_DIR/aligntest;
fi

if [ -d $EXPECTED_DIR/aligntest ]; then
    EXPECTED_DIR=$EXPECTED_DIR/aligntest;
fi

BAM_UTIL=$medir/../bin/bam
BAM1_1_FILE=Sample1.recal.bam
BAM1_1=bams/$BAM1_1_FILE
BAM1_2_FILE=Sample1.merged.bam
BAM1_2=tmp/alignment.pol/$BAM1_2_FILE
BAM2_1_FILE=Sample2.recal.bam
BAM2_1=bams/$BAM2_1_FILE
BAM2_2_FILE=Sample2.merged.bam
BAM2_2=tmp/alignment.pol/$BAM2_2_FILE

BAI1=Sample1.recal.bam.bai
BAI2=Sample2.recal.bam.bai

MAKEFILE1=align_Sample1.Makefile
MAKEFILE2=align_Sample2.Makefile

# qemp files may be in varying order based on the system
QEMPS="Sample1.recal.bam.qemp Sample2.recal.bam.qemp"
SKIP_QEMPS="-x Sample1.recal.bam.qemp -x Sample2.recal.bam.qemp"
QEMP_SUBDIR=tmp/alignment.recal

#   Diff the results
#set -e                          # Fail on errors
echo "Results from DIFF will be in $DIFFRESULTS"
diff -r $RESULTS_DIR/ $EXPECTED_DIR/ -x $BAI1 -x $BAI2 \
    -x $BAM1_1_FILE -x $BAM1_2_FILE -x $BAM2_1_FILE -x $BAM2_2_FILE $SKIP_QEMPS \
    -x $MAKEFILE1 -x $MAKEFILE2 -x $MAKEFILE1.log -x $MAKEFILE2.log -x $DIFF_FILE\
    -I '--in \[.*tmp/alignment.bwa/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$' \
    -I '--out \[.*tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$' \
    -I '--log \[.*tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam.log\]$' \
    -I '--fasta \[.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '--UR \[file:.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '# Started on:' \
    -I ' net.sf.picard.sam.MarkDuplicates INPUT=' \
    -I 'Stats\\BAM.*bams/Sample[1-2].recal.bam.*tmp/alignment.dedup/Sample[1-2].dedup.bam' \
    -I '-i (--in) = \[.*bams/Sample[1-2].recal.bam\]$' \
    -I '-r (--reference) = \[.*\]$' \
    -I '-b (--bfile) = \[.*hapmap_3.3.b37.chr20\]$' \
    -I '-o (--out) = \[.*/QCFiles/Sample[1-2].genoCheck\]$' \
    -I '^Writing output file .*/QCFiles/Sample[1-2].genoCheck$' \
    -I '^Finished writing output files .*/QCFiles/Sample[1-2].genoCheck.{bestRG,selfRG,bestSM,selfSM}$' \
    -I '^[0-9a-g]\{32\}  .*bams/Sample[1-2].recal.bam$' \
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
    -I '^Writing .*tmp/alignment.dedup/Sample[1-2].dedup.bam$' \
    -I '^\[bwa_sai2sam_pe_core\] time elapses: ' \
    -I '^\[bwa_sai2sam_pe_core\] refine gapped alignments\.\.\. ' \
    -I '^\[bwa_sai2sam_pe_core\] print alignments\.\.\. ' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    exit 2
fi

# Check the Makefiles
diff -r $RESULTS_DIR/Makefiles/ $EXPECTED_DIR/Makefiles/ \
    -x "*.log" \
    -I '.* aln .* .*fastq/Sample_[1-2]/File[1-2]_R[1-2].fastq.gz -f $(basename $@)' \
    -I '(.* sampe -r .* $(basename $^) .*fastq/Sample_[1-2]/File[1-2]_R1.fastq.gz .*fastq/Sample_[1-2]/File[1-2]_R2.fastq.gz | .* view -uhS - | .* sort -m .* - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log' \
    -I '^[A-Z_][A-Z_]* = '\
    -I '^OUT_DIR=.*$'\
    -I '^$(OUT_DIR)/Sample[1-2].OK: .*/Sample[1-2].recal.bam.done .*/Sample[1-2].genoCheck.done .*/Sample[1-2].qplot.done$' \
    -I '^.*/Sample[1-2].genoCheck.done: .*/Sample[1-2].recal.bam.done$' \
    -I '@echo ".* --verbose --vcf .* --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log"$' \
    -I '@.* --verbose --vcf .* --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\\nFailed VerifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-2].qplot.done: .*/Sample[1-2].recal.bam.done$' \
    -I '@echo ".* polishBam -f .* --AS .* --UR file:.* --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"$' \
    -I '@.* polishBam -f .* --AS .* --UR file:.* --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/fastq/Sample_[1-2]/File[1-2]_R[1-2].bam.done: .*/fastq/Sample_[1-2]/File[1-2]_R1.sai.done.*/fastq/Sample_[1-2]/File[1-2]_R2.sai.done$' \
    -I '^.*/fastq/Sample_[1-2]/File[1-2]_R[1-2].sai.done:$' \
    -I '^.*/fastq/Sample_[1-2]/File[1-2]_R1.bam.done: .*/fastq/Sample_[1-2]/File[1-2]_R1.bam.done$' \
    -I '.* mergeBam --out $(basename $@) $(subst .*,--in .*,$(basename $^))' \
    -I '^.*/Sample[1-2].merged.bam.done: .*/fastq/Sample_[1-2]/File1_R1.bam.done .*/fastq/Sample_[1-2]/File2_R1.bam.done $' \
    -I '@echo ".* dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err"$' \
    -I '@.* dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err || (echo "`grep -i -e abort -e error -e failed $(basename $@).err`" >&2; echo "\\nFailed Deduping step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).err $(OUT_DIR)/failLogs/$(notdir $(basename $@).err); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).err) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-2].dedup.bam.done: .*/Sample[1-2].merged.bam.done$' \
    -I 'cp .*/Sample[1-2].recal.bam $(basename $@)$' \
    -I '.* index $(basename $@)$' \
    -I 'mkdir -p .*$' \
    -I '@echo ".* recab --refFile .* --dbsnp .* --storeQualTag OQ --in $(basename $^) --out .*/Sample[1-2].recal.bam .* 2> $(basename $@).log"$' \
    -I '@.* recab --refFile .* --dbsnp .* --storeQualTag OQ --in $(basename $^) --out .*/Sample[1-2].recal.bam .* 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\\nFailed Recalibration step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-2].recal.bam.done: .*/Sample[1-2].dedup.bam.done$' \
    -I '@echo ".* --reference .* --dbsnp .* --gccontent .*.GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample[1-2]_recal,Sample[1-2]_dedup $(basename $^) .*/Sample[1-2].dedup.bam 2> $(basename $@).log"$' \
-I '@.* --reference .* --dbsnp .* --gccontent .*.GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample[1-2]_recal,Sample[1-2]_dedup $(basename $^) .*/Sample[1-2].dedup.bam 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\\nFailed QPLOT step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    >> $DIFFRESULTS
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

if [ ! -f $RESULTS_DIR/bams/$BAI1 ]; then
    echo "ERROR, Missing: $RESULTS_DIR/bams/$BAI1"
    exit 3
fi
if [ ! -f $RESULTS_DIR/bams/$BAI2 ]; then
    echo "ERROR, Missing: $RESULTS_DIR/bams/$BAI2"
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




