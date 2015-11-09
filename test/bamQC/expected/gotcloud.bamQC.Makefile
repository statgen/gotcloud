.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: bam_qplot bam_verifyBamID
<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.stats --Rcode <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.R --minMapQuality 0  <gotcloud_root>/test/align/expected/aligntest/bams/Sample1.recal.bam 2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.stats --Rcode <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.R --minMapQuality 0  <gotcloud_root>/test/align/expected/aligntest/bams/Sample2.recal.bam 2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/qplot --reference <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp <gotcloud_root>/test/chr20Ref/dbsnp135_chr20.vcf.gz --stats <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.stats --Rcode <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.R --minMapQuality 0  <gotcloud_root>/test/align/expected/aligntest/bams/Sample3.recal.bam 2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.OK

bam_qplot: <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.qplot.OK <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.OK <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.qplot.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.genoCheck.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <gotcloud_root>/test/align/expected/aligntest/bams/Sample1.recal.bam --out <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.genoCheck.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.genoCheck.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.genoCheck.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <gotcloud_root>/test/align/expected/aligntest/bams/Sample2.recal.bam --out <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.genoCheck.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.genoCheck.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.genoCheck.OK: | <outdir_path>/bamQC/bamQCtest/QCFiles/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/bamQC/bamQCtest/jobfiles local '<gotcloud_root>/bin/verifyBamID --bam <gotcloud_root>/test/align/expected/aligntest/bams/Sample3.recal.bam --out <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.genoCheck --vcf <gotcloud_root>/test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.genoCheck.err'
	touch <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.genoCheck.OK

bam_verifyBamID: <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID1.genoCheck.OK <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.genoCheck.OK <outdir_path>/bamQC/bamQCtest/QCFiles/SampleID3.genoCheck.OK

<outdir_path>/bamQC/bamQCtest/QCFiles/:
	mkdir -p <outdir_path>/bamQC/bamQCtest/QCFiles/

