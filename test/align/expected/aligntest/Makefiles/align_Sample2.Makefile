.DELETE_ON_ERROR:

PIPELINE_DIR = gotcloud
OUT_DIR = aligntest

all: $(OUT_DIR)/Sample2.OK

$(OUT_DIR)/Sample2.OK: $(FINAL_BAM_DIR)/Sample2.recal.bam.done $(QC_DIR)/Sample2.genoCheck.done $(QC_DIR)/Sample2.qplot.done
	rm -f $(SAI_FILES) $(ALN_FILES) $(POL_FILES) $(DEDUP_FILES) $(RECAL_FILES)
	touch $@

$(QC_DIR)/Sample2.genoCheck.done: $(FINAL_BAM_DIR)/Sample2.recal.bam.done
	mkdir -p $(@D)
	@echo "$(VERIFY_BAM_ID_EXE) --verbose --vcf $(HM3_VCF) --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log"
	@$(VERIFY_BAM_ID_EXE) --verbose --vcf $(HM3_VCF) --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed VerifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(QC_DIR)/Sample2.qplot.done: $(FINAL_BAM_DIR)/Sample2.recal.bam.done
	mkdir -p $(@D)
	@echo "$(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --gccontent $(REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample2_recal,Sample2_dedup $(basename $^) $(DEDUP_TMP)/Sample2.dedup.bam 2> $(basename $@).log"
	@$(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --gccontent $(REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample2_recal,Sample2_dedup $(basename $^) $(DEDUP_TMP)/Sample2.dedup.bam 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed QPLOT step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(FINAL_BAM_DIR)/Sample2.recal.bam.done: $(DEDUP_TMP)/Sample2.dedup.bam.done
	mkdir -p $(@D)
	mkdir -p $(RECAL_TMP)
	@echo "$(BAM_EXE) recab --refFile $(REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample2.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log"
	@$(BAM_EXE) recab --refFile $(REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample2.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed Recalibration step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	cp $(RECAL_TMP)/Sample2.recal.bam $(basename $@)
	$(SAMTOOLS_EXE) index $(basename $@)
	$(MD5SUM_EXE) $(basename $@) > $(basename $@).md5
	touch $@

$(DEDUP_TMP)/Sample2.dedup.bam.done: $(MERGE_TMP)/Sample2.merged.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err"
	@$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err || (echo "`grep -i -e abort -e error -e failed $(basename $@).err`" >&2; echo "\nFailed Deduping step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).err $(OUT_DIR)/failLogs/$(notdir $(basename $@).err); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).err) for more details" >&2; exit 1;)
	rm -f $(basename $@).err
	touch $@

$(MERGE_TMP)/Sample2.merged.bam.done: $(POL_TMP)/fastq/Sample_2/File1_R1.bam.done $(POL_TMP)/fastq/Sample_2/File2_R1.bam.done 
	mkdir -p $(@D)
	$(BAM_EXE) mergeBam --out $(basename $@) $(subst $(POL_TMP),--in $(POL_TMP),$(basename $^))
	touch $@

$(POL_TMP)/fastq/Sample_2/File1_R1.bam.done: $(ALN_TMP)/fastq/Sample_2/File1_R1.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"
	@$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(ALN_TMP)/fastq/Sample_2/File1_R1.bam.done: $(SAI_TMP)/fastq/Sample_2/File1_R1.sai.done $(SAI_TMP)/fastq/Sample_2/File1_R2.sai.done
	mkdir -p $(@D)
	($(BWA_EXE) sampe -r "@RG	ID:RGID2	SM:SampleID2	LB:Lib2	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) test/align/fastq/Sample_2/File1_R1.fastq.gz test/align/fastq/Sample_2/File1_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log
	@echo "(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1)"
	@(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1) || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "\nFailed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	touch $@

$(SAI_TMP)/fastq/Sample_2/File1_R1.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(SAI_TMP)/fastq/Sample_2/File1_R2.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(POL_TMP)/fastq/Sample_2/File2_R1.bam.done: $(ALN_TMP)/fastq/Sample_2/File2_R1.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"
	@$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(ALN_TMP)/fastq/Sample_2/File2_R1.bam.done: $(SAI_TMP)/fastq/Sample_2/File2_R1.sai.done $(SAI_TMP)/fastq/Sample_2/File2_R2.sai.done
	mkdir -p $(@D)
	($(BWA_EXE) sampe -r "@RG	ID:RGID2	SM:SampleID2	LB:Lib2	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) test/align/fastq/Sample_2/File2_R1.fastq.gz test/align/fastq/Sample_2/File2_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log
	@echo "(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1)"
	@(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1) || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "\nFailed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	touch $@

$(SAI_TMP)/fastq/Sample_2/File2_R1.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(SAI_TMP)/fastq/Sample_2/File2_R2.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) test/align/fastq/Sample_2/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

SAI_FILES = $(SAI_TMP)/fastq/Sample_2/File1_R1.sai $(SAI_TMP)/fastq/Sample_2/File1_R2.sai $(SAI_TMP)/fastq/Sample_2/File2_R1.sai $(SAI_TMP)/fastq/Sample_2/File2_R2.sai 

ALN_FILES = $(ALN_TMP)/fastq/Sample_2/File1_R1.bam $(ALN_TMP)/fastq/Sample_2/File2_R1.bam 

POL_FILES = $(POL_TMP)/fastq/Sample_2/File1_R1.bam $(POL_TMP)/fastq/Sample_2/File2_R1.bam 

DEDUP_FILES = $(DEDUP_TMP)/Sample2.dedup.bam 

RECAL_FILES = $(RECAL_TMP)/Sample2.recal.bam 
