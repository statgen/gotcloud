OUT_DIR = aligntest
SHELL := /bin/bash -o pipefail
.DELETE_ON_ERROR:


all: $(OUT_DIR)/Sample1.OK

$(OUT_DIR)/Sample1.OK: $(FINAL_BAM_DIR)/Sample1.recal.bam.done $(QC_DIR)/Sample1.genoCheck.done $(QC_DIR)/Sample1.qplot.done
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(QC_DIR)/Sample1.genoCheck.done: $(FINAL_BAM_DIR)/Sample1.recal.bam.done $(FINAL_BAM_DIR)/Sample1.recal.bam.bai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`"$(VERIFY_BAM_ID_EXE) --bam $(basename $<) --out $(basename $@) --vcf $(HM3_VCF)  2> $(basename $@).log"
	@$(VERIFY_BAM_ID_EXE) --bam $(basename $<) --out $(basename $@) --vcf $(HM3_VCF)  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed verifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(QC_DIR)/Sample1.qplot.done: $(FINAL_BAM_DIR)/Sample1.recal.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log"
	@$(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed qplot step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(FINAL_BAM_DIR)/Sample1.recal.bam.bai.done: $(DEDUP_TMP)/Sample1.recal.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(SAMTOOLS_EXE) index $(basename $^) 2> $(basename $@).log"
	@$(SAMTOOLS_EXE) index $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed index step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(FINAL_BAM_DIR)/Sample1.recal.bam.done: $(DEDUP_TMP)/Sample1.merged.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BAM_EXE) dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile $(REF) --dbsnp $(DBSNP_VCF)   --phoneHomeThinning 0 2> $(basename $@).log"
	@$(BAM_EXE) dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile $(REF) --dbsnp $(DBSNP_VCF)   --phoneHomeThinning 0 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed recab step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(POL_TMP)/fastq/Sample_1/File1_R1.bam.done: $(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0"
	@$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(POL_TMP)/fastq/Sample_1/File2_R1.bam.done: $(ALN_TMP)/fastq/Sample_1/File2_R1.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0"
	@$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(MERGE_TMP)/Sample1.merged.bam.done: $(POL_TMP)/fastq/Sample_1/File1_R1.bam.done $(POL_TMP)/fastq/Sample_1/File2_R1.bam.done 
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" gotcloud/bin/bam mergeBam --ignorePI --out $(basename $@) $(subst outdir/aligntest/tmp/alignment.pol,--in outdir/aligntest/tmp/alignment.pol,$(basename $^)) --phoneHomeThinning 0"
	@gotcloud/bin/bam mergeBam --ignorePI --out $(basename $@) $(subst outdir/aligntest/tmp/alignment.pol,--in outdir/aligntest/tmp/alignment.pol,$(basename $^)) --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed MergingBams step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done: $(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done $(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" ($(BWA_EXE) sampe -r "@RG	ID:RGID1	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log"
	@($(BWA_EXE) sampe -r "@RG	ID:RGID1	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "Failed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(ALN_TMP)/fastq/Sample_1/File2_R1.bam.done: $(SAI_TMP)/fastq/Sample_1/File2_R1.sai.done $(SAI_TMP)/fastq/Sample_1/File2_R2.sai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" ($(BWA_EXE) sampe -r "@RG	ID:RGID1a	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log"
	@($(BWA_EXE) sampe -r "@RG	ID:RGID1a	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "Failed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

$(SAI_TMP)/fastq/Sample_1/File2_R1.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

$(SAI_TMP)/fastq/Sample_1/File2_R2.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" $(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

