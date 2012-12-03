.PHONY : clean

ifeq ($(BIOPIPE_TEST_DIR),)
$(error BIOPIPE_TEST_DIR is not defined)
endif

EXPECTED_DIR=expected

ifeq ($(BASE_DIR),)
   BASE_DIR=../..
endif

BAM_UTIL=$(BASE_DIR)/bin/bam

BAM1_1_FILE=Sample1.recal.bam
BAM1_1=biopipetest/alignment.recal/$(BAM1_1_FILE)
BAM1_2_FILE=Sample1.merged.bam
BAM1_2=biopipetest/tmp/alignment.pol/$(BAM1_2_FILE)
BAM2_1_FILE=Sample2.recal.bam
BAM2_1=biopipetest/alignment.recal/$(BAM2_1_FILE)
BAM2_2_FILE=Sample2.merged.bam
BAM2_2=biopipetest/tmp/alignment.pol/$(BAM2_2_FILE)

BAI1=Sample1.recal.bam.bai
BAI2=Sample2.recal.bam.bai

all: test
#	-$(BASE_DIR)/bin/gen_biopipeline.pl --conf missing.conf
#	-$(BASE_DIR)/bin/gen_biopipeline.pl --conf test.conf
#	-$(BASE_DIR)/bin/gen_biopipeline.pl --indexFile badIndex.txt --out $(BIOPIPE_TEST_DIR)

test: clean
	@mkdir -p $(BIOPIPE_TEST_DIR)/biopipetest
	@$(BASE_DIR)/bin/gen_biopipeline.pl --conf test.conf --out_dir $(BIOPIPE_TEST_DIR)/biopipetest
	@echo "Running the test Makefiles with test log in: $(BIOPIPE_TEST_DIR)/biopipeTest.log";
	@(make -f $(BIOPIPE_TEST_DIR)/biopipetest/Makefiles/biopipe_Sample1.Makefile; make -f $(BIOPIPE_TEST_DIR)/biopipetest/Makefiles/biopipe_Sample2.Makefile) 1> $(BIOPIPE_TEST_DIR)/biopipeTest.log 2>&1
	@diff -r $(BIOPIPE_TEST_DIR)/biopipetest/ $(EXPECTED_DIR)/biopipetest/ -x $(BAI1) -x $(BAI2) -x $(BAM1_1_FILE) -x $(BAM1_2_FILE) -x $(BAM2_1_FILE) -x $(BAM2_2_FILE) -I '--in \[.*biopipetest/tmp/alignment.bwa/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$\' -I '--out \[.*biopipetest/tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam\]$\' -I '--log \[.*biopipetest/tmp/alignment.pol/fastq/Sample_[1-2]/File[1-2]_R1.bam.log\]$\' -I '--fasta \[.*chr20Ref/human_g1k_v37_chr20.fa\]$\' -I '--UR \[file:.*chr20Ref/human_g1k_v37_chr20.fa\]$\' -I "# Started on:" -I "# net.sf.picard.sam.MarkDuplicates INPUT=" -I 'Stats\\BAM.*/biopipetest/alignment.recal/Sample[1-2].recal.bam.*/biopipetest/tmp/alignment.dedup/Sample[1-2].dedup.bam' -I '-i (--in) = \[.*biopipetest/alignment.recal/Sample[1-2].recal.bam\]$\' -I '-r (--reference) = \[.*\]$\' -I '-b (--bfile) = \[.*hapmap_3.3.b37.chr20\]$\' -I '-o (--out) = \[.*/biopipetest/QCFiles/Sample[1-2].genoCheck\]$\' -I '^Writing output file .*/biopipetest/QCFiles/Sample[1-2].genoCheck$\' -I '^Finished writing output files .*/biopipetest/QCFiles/Sample[1-2].genoCheck.{bestRG,selfRG,bestSM,selfSM}$\' -I '^PIPELINE_DIR = ' -I '^OUT_DIR = ' -I '^FASTQ = ' -I '^INDEX_FILE = .*indexFile.txt$\' -I '^REF_DIR = .*chr20Ref$\' -I '^[0-9a-g]\{32\}  .*/biopipetest/alignment.recal/Sample[1-2].recal.bam$\' -I '^Reading the reference file ' -I '^Finished reading the reference file ' -I '^.*FamFile .*hapmap_3.3.b37.chr20.fam$\' -I '^.*BimFile .*hapmap_3.3.b37.chr20.bim$\' -I '^.*BedFile .*hapmap_3.3.b37.chr20.bed$\' -I '^Reading .*hapmap_3.3.b37.chr20.fam$\' -I '^Finished Reading .*hapmap_3.3.b37.chr20.fam containing 1397 individuals.* info$\' -I '^Reading .*/hapmap_3.3.b37.chr20.bim$\' -I '^Finished Reading .*/hapmap_3.3.b37.chr20.bim containing 37152 markers.* info$\' -I '^Opening .*/hapmap_3.3.b37.chr20.bed and checking the magic numbers$\' -I '$$(BWA_EXE) aln $$(BWA_QUAL) $$(BWA_THREADS) $$(FA_REF) .*fastq/Sample_[1-2]/File[1-2]_R[1-2].fastq.gz -f $$(basename $$@)' -I '($$(BWA_EXE) sampe -r .* $$(FA_REF) $$(basename $$^) .*fastq/Sample_[1-2]/File[1-2]_R1.fastq.gz .*fastq/Sample_[1-2]/File[1-2]_R2.fastq.gz | $$(SAMTOOLS_EXE) view -uhS - | $$(SAMTOOLS_EXE) sort -m $$(BWA_MAX_MEM) - $$(basename $$(basename $$@))) 2> $$(basename $$(basename $$@)).sampe.log' -I '^Writing recalibration table .*' -I '^Writing recalibrated file .*' -I 'Start: ' -I 'Start iterating SAM/BAM file .*' -I 'End: .*' -I '^Writing .*biopipetest/tmp/alignment.dedup/Sample[1-2].dedup.bam$\' -I '^\[bwa_sai2sam_pe_core\] time elapses: ' -I '^\[bwa_sai2sam_pe_core\] refine gapped alignments\.\.\. ' -I '^\[bwa_sai2sam_pe_core\] print alignments\.\.\. '
	@$(BAM_UTIL) diff --all --in1 $(BIOPIPE_TEST_DIR)/$(BAM1_1) --in2 $(EXPECTED_DIR)/$(BAM1_1)
	@$(BAM_UTIL) diff --all --in1 $(BIOPIPE_TEST_DIR)/$(BAM1_2) --in2 $(EXPECTED_DIR)/$(BAM1_2)
	@$(BAM_UTIL) diff --all --in1 $(BIOPIPE_TEST_DIR)/$(BAM2_1) --in2 $(EXPECTED_DIR)/$(BAM2_1)
	@$(BAM_UTIL) diff --all --in1 $(BIOPIPE_TEST_DIR)/$(BAM2_2) --in2 $(EXPECTED_DIR)/$(BAM2_2)
	@if [ ! -e $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI1) ]; then \
		echo "ERROR, Missing: $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI1)"; [ -e $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI1) ]; fi
	@if [ ! -e $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI2) ]; then \
		echo "ERROR, Missing: $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI2)"; [ -e $(BIOPIPE_TEST_DIR)/biopipetest/alignment.recal/$(BAI2) ]; fi
clean:
	rm -rf $(BIOPIPE_TEST_DIR)/biopipetest
