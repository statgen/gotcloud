.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: recab_mergeBam singleBamRecab multiBamRecab recab_indexBam recabQC_qplot recabQC_verifyBamID
recab/mergedBams/SampleID1.bam.OK: | recab/mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/recabQC/bams/Sample1_File1.bam --in test/recabQC/bams/Sample1_File2.bam --out recab/mergedBams/SampleID1.bam'
	touch recab/mergedBams/SampleID1.bam.OK

recab/mergedBams/SampleID2.bam.OK: | recab/mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/recabQC/bams/Sample2_File1.bam --in test/recabQC/bams/Sample2_File2.bam --out recab/mergedBams/SampleID2.bam'
	touch recab/mergedBams/SampleID2.bam.OK

recab_mergeBam: recab/mergedBams/SampleID1.bam.OK recab/mergedBams/SampleID2.bam.OK

recab/SampleID3.recal.bam.OK: | recab/
	scripts/runcluster.pl local 'bin/bam dedup --log recab/SampleID3.recal.bam.metrics --recab --in test/recabQC/bams/Sample3_File1.bam --out recab/SampleID3.recal.bam --refFile test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch recab/SampleID3.recal.bam.OK

singleBamRecab: recab/SampleID3.recal.bam.OK

recab/SampleID1.recal.bam.OK: recab/mergedBams/SampleID1.bam.OK | recab/
	scripts/runcluster.pl local 'bin/bam dedup --log recab/SampleID1.recal.bam.metrics --recab --in recab/mergedBams/SampleID1.bam --out recab/SampleID1.recal.bam --refFile test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch recab/SampleID1.recal.bam.OK

recab/SampleID2.recal.bam.OK: recab/mergedBams/SampleID2.bam.OK | recab/
	scripts/runcluster.pl local 'bin/bam dedup --log recab/SampleID2.recal.bam.metrics --recab --in recab/mergedBams/SampleID2.bam --out recab/SampleID2.recal.bam --refFile test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch recab/SampleID2.recal.bam.OK

multiBamRecab: recab/SampleID1.recal.bam.OK recab/SampleID2.recal.bam.OK

recab/SampleID1.recal.bam.bai.OK: recab/SampleID1.recal.bam.OK | recab/
	scripts/runcluster.pl local 'bin/samtools index recab/SampleID1.recal.bam 2> recab/SampleID1.recal.bam.bai.log'
	touch recab/SampleID1.recal.bam.bai.OK

recab/SampleID2.recal.bam.bai.OK: recab/SampleID2.recal.bam.OK | recab/
	scripts/runcluster.pl local 'bin/samtools index recab/SampleID2.recal.bam 2> recab/SampleID2.recal.bam.bai.log'
	touch recab/SampleID2.recal.bam.bai.OK

recab/SampleID3.recal.bam.bai.OK: recab/SampleID3.recal.bam.OK | recab/
	scripts/runcluster.pl local 'bin/samtools index recab/SampleID3.recal.bam 2> recab/SampleID3.recal.bam.bai.log'
	touch recab/SampleID3.recal.bam.bai.OK

recab_indexBam: recab/SampleID1.recal.bam.bai.OK recab/SampleID2.recal.bam.bai.OK recab/SampleID3.recal.bam.bai.OK

recab/QCFiles/SampleID1.qplot.OK: recab/SampleID1.recal.bam.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats recab/QCFiles/SampleID1.qplot.stats --Rcode recab/QCFiles/SampleID1.qplot.R --minMapQuality 0 --bamlabel recal recab/SampleID1.recal.bam 2> recab/QCFiles/SampleID1.qplot.err'
	touch recab/QCFiles/SampleID1.qplot.OK

recab/QCFiles/SampleID2.qplot.OK: recab/SampleID2.recal.bam.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats recab/QCFiles/SampleID2.qplot.stats --Rcode recab/QCFiles/SampleID2.qplot.R --minMapQuality 0 --bamlabel recal recab/SampleID2.recal.bam 2> recab/QCFiles/SampleID2.qplot.err'
	touch recab/QCFiles/SampleID2.qplot.OK

recab/QCFiles/SampleID3.qplot.OK: recab/SampleID3.recal.bam.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats recab/QCFiles/SampleID3.qplot.stats --Rcode recab/QCFiles/SampleID3.qplot.R --minMapQuality 0 --bamlabel recal recab/SampleID3.recal.bam 2> recab/QCFiles/SampleID3.qplot.err'
	touch recab/QCFiles/SampleID3.qplot.OK

recabQC_qplot: recab/QCFiles/SampleID1.qplot.OK recab/QCFiles/SampleID2.qplot.OK recab/QCFiles/SampleID3.qplot.OK

recab/QCFiles/SampleID1.genoCheck.OK: recab/SampleID1.recal.bam.OK recab/SampleID1.recal.bam.bai.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam recab/SampleID1.recal.bam --out recab/QCFiles/SampleID1.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> recab/QCFiles/SampleID1.genoCheck.err'
	touch recab/QCFiles/SampleID1.genoCheck.OK

recab/QCFiles/SampleID2.genoCheck.OK: recab/SampleID2.recal.bam.OK recab/SampleID2.recal.bam.bai.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam recab/SampleID2.recal.bam --out recab/QCFiles/SampleID2.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> recab/QCFiles/SampleID2.genoCheck.err'
	touch recab/QCFiles/SampleID2.genoCheck.OK

recab/QCFiles/SampleID3.genoCheck.OK: recab/SampleID3.recal.bam.OK recab/SampleID3.recal.bam.bai.OK | recab/QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam recab/SampleID3.recal.bam --out recab/QCFiles/SampleID3.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> recab/QCFiles/SampleID3.genoCheck.err'
	touch recab/QCFiles/SampleID3.genoCheck.OK

recabQC_verifyBamID: recab/QCFiles/SampleID1.genoCheck.OK recab/QCFiles/SampleID2.genoCheck.OK recab/QCFiles/SampleID3.genoCheck.OK

recab/:
	mkdir -p recab/

recab/QCFiles/:
	mkdir -p recab/QCFiles/

recab/mergedBams/:
	mkdir -p recab/mergedBams/

