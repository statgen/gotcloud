.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: recab_mergeBam singleBamRecab multiBamRecab recab_indexBam recabQC_qplot recabQC_verifyBamID
<outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam.OK: | <outdir_path>/recabQC/recabQCtest/recab/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/recabQC/bams/Sample1_File1.bam --in <gotcloud_root>/test/recabQC/bams/Sample1_File2.bam --out <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam'
	touch <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam.OK

<outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam.OK: | <outdir_path>/recabQC/recabQCtest/recab/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/recabQC/bams/Sample2_File1.bam --in <gotcloud_root>/test/recabQC/bams/Sample2_File2.bam --out <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam'
	touch <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam.OK

recab_mergeBam: <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam.OK <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK: | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/bam dedup --log <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.metrics --recab --in <gotcloud_root>/test/recabQC/bams/Sample3_File1.bam --out <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam --refFile <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK

singleBamRecab: <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK: <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/bam dedup --log <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.metrics --recab --in <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID1.bam --out <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam --refFile <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK: <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/bam dedup --log <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.metrics --recab --in <outdir_path>/recabQC/recabQCtest/recab/mergedBams/SampleID2.bam --out <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam --refFile <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz  --phoneHomeThinning 10'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK

multiBamRecab: <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.bai.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.bai.log'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.bai.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.bai.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.bai.log'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.bai.OK

<outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.bai.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.bai.log'
	touch <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.bai.OK

recab_indexBam: <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.bai.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.bai.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.bai.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.stats --Rcode <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.R --minMapQuality 0 --bamlabel recal <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.stats --Rcode <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.R --minMapQuality 0 --bamlabel recal <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.stats --Rcode <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.R --minMapQuality 0 --bamlabel recal <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam 2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.OK

recabQC_qplot: <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.OK <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.qplot.OK <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.qplot.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.genoCheck.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam.bai.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <outdir_path>/recabQC/recabQCtest/recab/SampleID1.recal.bam --out <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.genoCheck.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.genoCheck.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.genoCheck.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam.bai.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <outdir_path>/recabQC/recabQCtest/recab/SampleID2.recal.bam --out <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.genoCheck.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.genoCheck.OK

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.genoCheck.OK: <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.OK <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam.bai.OK | <outdir_path>/recabQC/recabQCtest/recab/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/recabQC/recabQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <outdir_path>/recabQC/recabQCtest/recab/SampleID3.recal.bam --out <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.genoCheck.err'
	touch <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.genoCheck.OK

recabQC_verifyBamID: <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.genoCheck.OK <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID2.genoCheck.OK <outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID3.genoCheck.OK

<outdir_path>/recabQC/recabQCtest/recab/:
	mkdir -p <outdir_path>/recabQC/recabQCtest/recab/

<outdir_path>/recabQC/recabQCtest/recab/QCFiles/:
	mkdir -p <outdir_path>/recabQC/recabQCtest/recab/QCFiles/

<outdir_path>/recabQC/recabQCtest/recab/mergedBams/:
	mkdir -p <outdir_path>/recabQC/recabQCtest/recab/mergedBams/

