OUT_DIR=<outdir_path>
SHELL := /bin/bash -o pipefail
.DELETE_ON_ERROR:


all: $(OUT_DIR)/Sample2.OK

$(OUT_DIR)/Sample2.OK: <outdir_path>/QCFiles/Sample2.genoCheck.done <outdir_path>/QCFiles/Sample2.qplot.done <outdir_path>/bams/Sample2.recal.bam.bai.done <outdir_path>/bams/Sample2.recal.bam.done
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/QCFiles/Sample2.genoCheck.done: <outdir_path>/bams/Sample2.recal.bam.done <outdir_path>/bams/Sample2.recal.bam.bai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/verifyBamID --bam $(basename $<) --out $(basename $@) --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> $(basename $@).log"
	@<gotcloud_root>/bin/verifyBamID --bam $(basename $<) --out $(basename $@) --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed verifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/QCFiles/Sample2.qplot.done: <outdir_path>/bams/Sample2.recal.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`"  <gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log"
	@ <gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel recal $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed qplot step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/bams/Sample2.recal.bam.bai.done: <outdir_path>/bams/Sample2.recal.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/samtools index $(basename $^) 2> $(basename $@).log"
	@<gotcloud_root>/bin/samtools index $(basename $^) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed index step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/bams/Sample2.recal.bam.done: <outdir_path>/tmp/alignment.pol/Sample2.merged.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bam dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz    --phoneHomeThinning 0  2> $(basename $@).log"
	@<gotcloud_root>/bin/bam dedup --log $(basename $@).metrics  --recab --in $(basename $^) --out $(basename $@) --refFile <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz    --phoneHomeThinning 0  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed recab step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/alignment.pol/fastq/Sample_2/File1_R1.bam.done: <outdir_path>/tmp/alignment.aln/fastq/Sample_2/File1_R1.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bam polishBam -f <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --AS NCBI37 --UR file:<gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0"
	@<gotcloud_root>/bin/bam polishBam -f <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --AS NCBI37 --UR file:<gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/alignment.pol/fastq/Sample_2/File2_R1.bam.done: <outdir_path>/tmp/alignment.aln/fastq/Sample_2/File2_R1.bam.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bam polishBam -f <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --AS NCBI37 --UR file:<gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0"
	@<gotcloud_root>/bin/bam polishBam -f <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --AS NCBI37 --UR file:<gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/alignment.pol/Sample2.merged.bam.done: <outdir_path>/tmp/alignment.pol/fastq/Sample_2/File1_R1.bam.done <outdir_path>/tmp/alignment.pol/fastq/Sample_2/File2_R1.bam.done 
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bam mergeBam --ignorePI --out $(basename $@) $(subst <outdir_path>/tmp/alignment.pol,--in <outdir_path>/tmp/alignment.pol,$(basename $^)) --phoneHomeThinning 0"
	@<gotcloud_root>/bin/bam mergeBam --ignorePI --out $(basename $@) $(subst <outdir_path>/tmp/alignment.pol,--in <outdir_path>/tmp/alignment.pol,$(basename $^)) --phoneHomeThinning 0 || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed MergingBams step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/alignment.aln/fastq/Sample_2/File1_R1.bam.done: <outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File1_R1.sai.done <outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File1_R2.sai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" (<gotcloud_root>/bin/bwa sampe -r  "@RG\tID:RGID2\tSM:SampleID2\tLB:Lib2\tCN:UM\tPL:ILLUMINA" <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa $(basename $^) <gotcloud_root>/test/align/fastq/Sample_2/File1_R1.fastq.gz <gotcloud_root>/test/align/fastq/Sample_2/File1_R2.fastq.gz | <gotcloud_root>/bin/samtools view -uhS - | <gotcloud_root>/bin/samtools sort -m 2000000000 - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log"
	@(<gotcloud_root>/bin/bwa sampe -r  "@RG\tID:RGID2\tSM:SampleID2\tLB:Lib2\tCN:UM\tPL:ILLUMINA" <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa $(basename $^) <gotcloud_root>/test/align/fastq/Sample_2/File1_R1.fastq.gz <gotcloud_root>/test/align/fastq/Sample_2/File1_R2.fastq.gz | <gotcloud_root>/bin/samtools view -uhS - | <gotcloud_root>/bin/samtools sort -m 2000000000 - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "Failed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File1_R1.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@<gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File1_R2.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@<gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/tmp/alignment.aln/fastq/Sample_2/File2_R1.bam.done: <outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File2_R1.sai.done <outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File2_R2.sai.done
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" (<gotcloud_root>/bin/bwa sampe -r  "@RG\tID:RGID2\tSM:SampleID2\tLB:Lib2\tCN:UM\tPL:ILLUMINA" <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa $(basename $^) <gotcloud_root>/test/align/fastq/Sample_2/File2_R1.fastq.gz <gotcloud_root>/test/align/fastq/Sample_2/File2_R2.fastq.gz | <gotcloud_root>/bin/samtools view -uhS - | <gotcloud_root>/bin/samtools sort -m 2000000000 - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log"
	@(<gotcloud_root>/bin/bwa sampe -r  "@RG\tID:RGID2\tSM:SampleID2\tLB:Lib2\tCN:UM\tPL:ILLUMINA" <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa $(basename $^) <gotcloud_root>/test/align/fastq/Sample_2/File2_R1.fastq.gz <gotcloud_root>/test/align/fastq/Sample_2/File2_R2.fastq.gz | <gotcloud_root>/bin/samtools view -uhS - | <gotcloud_root>/bin/samtools sort -m 2000000000 - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "Failed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@
	rm -f $(basename $^)

<outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File2_R1.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@<gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File2_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

<outdir_path>/tmp/bwa.sai.t/fastq/Sample_2/File2_R2.sai.done:
	mkdir -p $(@D)
	@echo `date +'%F.%H:%M:%S'`" <gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@<gotcloud_root>/bin/bwa aln -q 15 -t 1 <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa <gotcloud_root>/test/align/fastq/Sample_2/File2_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "Failed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	@echo `date +'%F.%H:%M:%S'` touch $@; touch $@

