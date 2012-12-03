.DELETE_ON_ERROR:

PIPELINE_DIR = /home/mktrost/gotcloud
OUT_DIR = /home/mktrost/gotcloud/test/align/T3/biopipetest
KEEP_TMP = 0
KEEP_LOG = 0
INDEX_FILE = /home/mktrost/gotcloud/test/align/indexFile.txt
REF_DIR = /home/mktrost/gotcloud/test/align/chr20Ref
AS = NCBI37
FA_REF = $(REF_DIR)/human_g1k_v37_chr20.fa
DBSNP_VCF = $(REF_DIR)/dbsnp.b130.ncbi37.chr20.vcf.gz
PLINK = $(REF_DIR)/hapmap_3.3.b37.chr20
RUN_QPLOT = 1
RUN_VERIFY_BAM_ID = 1
RECAL_DIR = $(OUT_DIR)/alignment.recal
BIN_DIR = $(PIPELINE_DIR)/bin
MD5SUM_EXE = md5sum
SAMTOOLS_EXE = $(BIN_DIR)/samtools
BWA_EXE = $(BIN_DIR)/bwa
VERIFY_BAM_ID_EXE = $(BIN_DIR)/verifyBamID
QPLOT_EXE = $(BIN_DIR)/qplot
BAM_EXE = $(BIN_DIR)/bam
MERGE_JAR = $(BIN_DIR)/MergeSamFiles.jar
JAVA_EXE = java
JAVA_MEM = -Xmx4g
BWA_THREADS = -t 1
BWA_QUAL = -q 15
BWA_MAX_MEM = 2000000000
TMP_DIR = $(OUT_DIR)/tmp
SAI_TMP = $(TMP_DIR)/bwa.sai.t
ALN_TMP = $(TMP_DIR)/alignment.bwa
POL_TMP = $(TMP_DIR)/alignment.pol
MERGE_TMP = $(TMP_DIR)/alignment.pol
DEDUP_TMP = $(TMP_DIR)/alignment.dedup
RECAL_TMP = $(TMP_DIR)/alignment.recal
QC_DIR = $(OUT_DIR)/QCFiles

all: $(OUT_DIR)/Sample1.OK

$(OUT_DIR)/Sample1.OK: $(RECAL_DIR)/Sample1.recal.bam.done $(QC_DIR)/Sample1.genoCheck.done $(QC_DIR)/Sample1.qplot.done
	rm -f $(SAI_FILES) $(ALN_FILES) $(POL_FILES) $(DEDUP_FILES) $(RECAL_FILES)
	touch $@

$(QC_DIR)/Sample1.genoCheck.done: $(RECAL_DIR)/Sample1.recal.bam.done
	mkdir -p $(@D)
	@echo "$(VERIFY_BAM_ID_EXE) --reference $(FA_REF) -v -m 10 -g 5e-3 --selfonly -d 50 -b $(PLINK) --in $(basename $^) --out $(basename $@) 2> $(basename $@).log"
	@$(VERIFY_BAM_ID_EXE) --reference $(FA_REF) -v -m 10 -g 5e-3 --selfonly -d 50 -b $(PLINK) --in $(basename $^) --out $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed VerifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(QC_DIR)/Sample1.qplot.done: $(RECAL_DIR)/Sample1.recal.bam.done
	mkdir -p $(@D)
	@echo "$(QPLOT_EXE) --reference $(FA_REF) --dbsnp $(DBSNP_VCF) --gccontent $(FA_REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample1_recal,Sample1_dedup $(basename $^) $(DEDUP_TMP)/Sample1.dedup.bam 2> $(basename $@).log"
	@$(QPLOT_EXE) --reference $(FA_REF) --dbsnp $(DBSNP_VCF) --gccontent $(FA_REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample1_recal,Sample1_dedup $(basename $^) $(DEDUP_TMP)/Sample1.dedup.bam 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed QPLOT step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(RECAL_DIR)/Sample1.recal.bam.done: $(DEDUP_TMP)/Sample1.dedup.bam.done
	mkdir -p $(@D)
	mkdir -p $(RECAL_TMP)
	@echo "$(BAM_EXE) recab --refFile $(FA_REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample1.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log"
	@$(BAM_EXE) recab --refFile $(FA_REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample1.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed Recalibration step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	cp $(RECAL_TMP)/Sample1.recal.bam $(basename $@)
	$(SAMTOOLS_EXE) index $(basename $@)
	$(MD5SUM_EXE) $(basename $@) > $(basename $@).md5
	touch $@

$(DEDUP_TMP)/Sample1.dedup.bam.done: $(MERGE_TMP)/Sample1.merged.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err"
	@$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err || (echo "`grep -i -e abort -e error -e failed $(basename $@).err`" >&2; echo "\nFailed Deduping step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).err $(OUT_DIR)/failLogs/$(notdir $(basename $@).err); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).err) for more details" >&2; exit 1;)
	rm -f $(basename $@).err
	touch $@

$(MERGE_TMP)/Sample1.merged.bam.done: $(POL_TMP)/fastq/Sample_1/File1_R1.bam.done $(POL_TMP)/fastq/Sample_1/File2_R1.bam.done 
	mkdir -p $(@D)
	$(JAVA_EXE) -jar $(JAVA_MEM) $(MERGE_JAR) VALIDATION_STRINGENCY=SILENT AS=true O=$(basename $@) $(subst $(POL_TMP),I=$(POL_TMP),$(basename $^))
	touch $@

$(POL_TMP)/fastq/Sample_1/File1_R1.bam.done: $(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) polishBam -f $(FA_REF) --AS $(AS) --UR file:$(FA_REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"
	@$(BAM_EXE) polishBam -f $(FA_REF) --AS $(AS) --UR file:$(FA_REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done: $(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done $(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done
	mkdir -p $(@D)
	($(BWA_EXE) sampe -r "@RG	ID:RGID1	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(FA_REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log
	@echo "(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1)"
	@(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1) || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "\nFailed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(POL_TMP)/fastq/Sample_1/File2_R1.bam.done: $(ALN_TMP)/fastq/Sample_1/File2_R1.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) polishBam -f $(FA_REF) --AS $(AS) --UR file:$(FA_REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"
	@$(BAM_EXE) polishBam -f $(FA_REF) --AS $(AS) --UR file:$(FA_REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(ALN_TMP)/fastq/Sample_1/File2_R1.bam.done: $(SAI_TMP)/fastq/Sample_1/File2_R1.sai.done $(SAI_TMP)/fastq/Sample_1/File2_R2.sai.done
	mkdir -p $(@D)
	($(BWA_EXE) sampe -r "@RG	ID:RGID1a	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(FA_REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log
	@echo "(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1)"
	@(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1) || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "\nFailed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File2_R1.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File2_R2.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(FA_REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

SAI_FILES = $(SAI_TMP)/fastq/Sample_1/File1_R1.sai $(SAI_TMP)/fastq/Sample_1/File1_R2.sai $(SAI_TMP)/fastq/Sample_1/File2_R1.sai $(SAI_TMP)/fastq/Sample_1/File2_R2.sai 

ALN_FILES = $(ALN_TMP)/fastq/Sample_1/File1_R1.bam $(ALN_TMP)/fastq/Sample_1/File2_R1.bam 

POL_FILES = $(POL_TMP)/fastq/Sample_1/File1_R1.bam $(POL_TMP)/fastq/Sample_1/File2_R1.bam 

DEDUP_FILES = $(DEDUP_TMP)/Sample1.dedup.bam 

RECAL_FILES = $(RECAL_TMP)/Sample1.recal.bam 
