.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: bam_qplot bam_verifyBamID
QCFiles/SampleID1.qplot.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats QCFiles/SampleID1.qplot.stats --Rcode QCFiles/SampleID1.qplot.R --minMapQuality 0  test/align/expected/aligntest/bams/Sample1.recal.bam 2> QCFiles/SampleID1.qplot.err'
	touch QCFiles/SampleID1.qplot.OK

QCFiles/SampleID2.qplot.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats QCFiles/SampleID2.qplot.stats --Rcode QCFiles/SampleID2.qplot.R --minMapQuality 0  test/align/expected/aligntest/bams/Sample2.recal.bam 2> QCFiles/SampleID2.qplot.err'
	touch QCFiles/SampleID2.qplot.OK

QCFiles/SampleID3.qplot.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/qplot --reference test/chr20Ref/human_g1k_v37_chr20.fa --dbsnp test/chr20Ref/dbsnp135_chr20.vcf.gz --stats QCFiles/SampleID3.qplot.stats --Rcode QCFiles/SampleID3.qplot.R --minMapQuality 0  test/align/expected/aligntest/bams/Sample3.recal.bam 2> QCFiles/SampleID3.qplot.err'
	touch QCFiles/SampleID3.qplot.OK

bam_qplot: QCFiles/SampleID1.qplot.OK QCFiles/SampleID2.qplot.OK QCFiles/SampleID3.qplot.OK

QCFiles/SampleID1.genoCheck.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam test/align/expected/aligntest/bams/Sample1.recal.bam --out QCFiles/SampleID1.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> QCFiles/SampleID1.genoCheck.err'
	touch QCFiles/SampleID1.genoCheck.OK

QCFiles/SampleID2.genoCheck.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam test/align/expected/aligntest/bams/Sample2.recal.bam --out QCFiles/SampleID2.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> QCFiles/SampleID2.genoCheck.err'
	touch QCFiles/SampleID2.genoCheck.OK

QCFiles/SampleID3.genoCheck.OK: | QCFiles/
	scripts/runcluster.pl local 'bin/verifyBamID --bam test/align/expected/aligntest/bams/Sample3.recal.bam --out QCFiles/SampleID3.genoCheck --vcf test/chr20Ref/hapmap_3.3.b37.sites.chr20.vcf.gz  2> QCFiles/SampleID3.genoCheck.err'
	touch QCFiles/SampleID3.genoCheck.OK

bam_verifyBamID: QCFiles/SampleID1.genoCheck.OK QCFiles/SampleID2.genoCheck.OK QCFiles/SampleID3.genoCheck.OK

QCFiles/:
	mkdir -p QCFiles/

