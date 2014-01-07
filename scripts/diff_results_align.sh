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

SAMPLES=( Sample1 Sample2 Sample3 )

RECAL_BAMS=( "${SAMPLES[@]/%/.recal.bam}" )
BAIS=( "${RECAL_BAMS[@]/%/.bai}" )
# qemp files may be in varying order based on the system
QEMPS=( "${RECAL_BAMS[@]/%/.qemp}" )

SKIP_FILES=${RECAL_BAMS[@]/#/"-x "}
SKIP_FILES+=" "${BAIS[@]/#/"-x "}
SKIP_FILES+=" "${QEMPS[@]/#/"-x "}

QEMP_SUBDIR=bams

#   Diff the results
#set -e                          # Fail on errors
echo "Results from DIFF will be in $DIFFRESULTS"
diff -r $RESULTS_DIR/ $EXPECTED_DIR/ $SKIP_FILES \
    -x Makefiles -x $DIFF_FILE\
    -I '--in \[.*tmp/alignment.bwa/fastq/Sample_[1-3]/File[1-2]_R1.bam\]$' \
    -I '--out \[.*tmp/alignment.pol/fastq/Sample_[1-3]/File[1-2]_R1.bam\]$' \
    -I '--log \[.*tmp/alignment.pol/fastq/Sample_[1-3]/File[1-2]_R1.bam.log\]$' \
    -I '--fasta \[.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '--UR \[file:.*chr20Ref/human_g1k_v37_chr20.fa\]$' \
    -I '# Started on:' \
    -I ' net.sf.picard.sam.MarkDuplicates INPUT=' \
    -I '^Stats\\BAM.*bams/Sample[1-3].recal.bam$' \
    -I '-i (--in) = \[.*bams/Sample[1-3].recal.bam\]$' \
    -I '-r (--reference) = \[.*\]$' \
    -I '-b (--bfile) = \[.*hapmap_3.3.b37.chr20\]$' \
    -I '-o (--out) = \[.*/QCFiles/Sample[1-3].genoCheck\]$' \
    -I '^Writing output file .*/QCFiles/Sample[1-3].genoCheck$' \
    -I '^Finished writing output files .*/QCFiles/Sample[1-3].genoCheck.{bestRG,selfRG,bestSM,selfSM}$' \
    -I '^[0-9a-g]\{32\}  .*bams/Sample[1-3].recal.bam$' \
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
    -I '^Writing .*/bams/Sample[1-3].recal.bam$' \
    -I '^\[bwa_sai2sam_pe_core\] time elapses: ' \
    -I '^\[bwa_sai2sam_pe_core\] refine gapped alignments\.\.\. ' \
    -I '^\[bwa_sai2sam_pe_core\] print alignments\.\.\. ' \
    -I '^pdf(file=".*QCFiles/Sample[1-3].qplot.pdf", height=12, width=12);$' \
    > $DIFFRESULTS
if [ "$?" != "0" ]; then
    echo "Failed results validation. See mismatches in $DIFFRESULTS"
    exit 2
fi

# Do not compare the align.conf files because
# many of the settings have the paths in them
# which will vary between runs.

# Check the Makefiles
diff -r -x align.conf -x jobfiles $RESULTS_DIR/Makefiles/ $EXPECTED_DIR/Makefiles/ \
    -x "*.log" \
    -I '.* aln .* .*fastq/Sample_[1-3]/File[1-2]_R[1-2].fastq.gz -f $(basename $@)' \
    -I '(.* sampe -r .* $(basename $^) .*fastq/Sample_[1-3]/File[1-2]_R1.fastq.gz .*fastq/Sample_[1-3]/File[1-2]_R2.fastq.gz | .* view -uhS - | .* sort -m .* - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log' \
    -I '^[A-Z_][A-Z_]* = '\
    -I '^OUT_DIR=.*$'\
    -I '^$(OUT_DIR)/Sample[1-3].OK: .*/Sample[1-3].recal.bam.done .*/Sample[1-3].genoCheck.done .*/Sample[1-3].qplot.done$' \
    -I '^.*/Sample[1-3].recal.bam.bai.done: .*/Sample[1-3].recal.bam.done$' \
    -I '^.*/Sample[1-3].genoCheck.done: .*/Sample[1-3].recal.bam.done .*/Sample[1-3].recal.bam.bai.done$' \
    -I '@echo .*".* --bam $(basename $<) --out $(basename $@) --verbose --vcf .*  2> $(basename $@).log"$' \
    -I '@.* --bam $(basename $<) --out $(basename $@) --verbose --vcf .*  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed verifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-3].qplot.done: .*/Sample[1-3].recal.bam.done$' \
    -I '@echo .*".* polishBam -f .* --AS .* --UR file:.* --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0"$' \
    -I '@.* polishBam -f .* --AS .* --UR file:.* --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/fastq/Sample_[1-3]/File[1-2]_R[1-2].bam.done: .*/fastq/Sample_[1-3]/File[1-2]_R1.sai.done.*/fastq/Sample_[1-3]/File[1-2]_R2.sai.done$' \
    -I '^.*/fastq/Sample_[1-3]/File[1-2]_R[1-2].sai.done:$' \
    -I '^.*/fastq/Sample_[1-3]/File[1-2]_R1.bam.done: .*/fastq/Sample_[1-3]/File[1-2]_R1.bam.done$' \
    -I '.* mergeBam --ignorePI --out $(basename $@) $(subst .*,--in .*,$(basename $^)) --phoneHomeThinning 0' \
    -I '^.*/Sample[1-2].merged.bam.done: .*/fastq/Sample_[1-2]/File1_R1.bam.done .*/fastq/Sample_[1-2]/File2_R1.bam.done $' \
    -I '^.*/Sample3.merged.bam.done: .*/fastq/Sample_3/File1_R1.bam.done $' \
    -I '@echo .*".* dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics  2> $(basename $@).log"$' \
    -I '@.* dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed dedup step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-3].dedup.bam.done: .*/Sample[1-3].merged.bam.done$' \
    -I 'cp .*/Sample[1-3].recal.bam $(basename $@)$' \
    -I '@echo .*".* index $(basename $^) 2> $(basename $@).log"$' \
    -I '@.* index $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed index step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I 'mkdir -p .*$' \
    -I '@echo .*".* dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile .* --dbsnp .* --storeQualTag OQ  --phoneHomeThinning 0 2> $(basename $@).log"$' \
    -I '@.* dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile .* --dbsnp .* --storeQualTag OQ  --phoneHomeThinning 0 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed recab step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
    -I '^.*/Sample[1-3].recal.bam.done: .*/Sample[1-3].merged.bam.done$' \
    -I '@echo .*".* --reference .* --dbsnp .* --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log"$' \
    -I '@.* --reference .* --dbsnp .* --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed qplot step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)$' \
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

for bai in $BAIS; do
    if [ ! -f $RESULTS_DIR/bams/$bai ]; then
        echo "ERROR, Missing: $RESULTS_DIR/bams/$bai"
        exit 3
    fi
done

# Add the directories to the arrays.
RECAL_BAMS_D=( "${RECAL_BAMS[@]/#/bams/}" )

set -e                          # Fail on errors
for file in $RECAL_BAMS_D
do
  $BAM_UTIL diff --all --in1 $RESULTS_DIR/$file --in2 $EXPECTED_DIR/$file >> $DIFFRESULTS
  if [ `wc -l $DIFFRESULTS|cut -f 1 -d ' '` != "0" ]; then
      echo "$RESULTS_DIR/$file does not match $EXPECTED_DIR/$file. See mismatches in $DIFFRESULTS"
      exit 2
  fi
done

echo "Successful comparison of data in '$RESULTS_DIR' and '$EXPECTED_DIR'"
exit 0




