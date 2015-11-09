.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: indel_mergeBam indel_indexMBam singleBamDiscover multiBamDiscover indexD merge indexM probes indexP singleBamGenotype multiBamGenotype indexG concatG indexCG mergeG indexMG concat indexC
<outdir_path>/indel/mergedBams/NA12045.bam.OK: | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/umake/bams/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in <gotcloud_root>/test/umake/bams/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out <outdir_path>/indel/mergedBams/NA12045.bam'
	touch <outdir_path>/indel/mergedBams/NA12045.bam.OK

<outdir_path>/indel/mergedBams/NA12249.bam.OK: | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/umake/bams/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in <gotcloud_root>/test/umake/bams/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out <outdir_path>/indel/mergedBams/NA12249.bam'
	touch <outdir_path>/indel/mergedBams/NA12249.bam.OK

<outdir_path>/indel/mergedBams/NA11931.bam.OK: | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/umake/bams/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in <gotcloud_root>/test/umake/bams/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out <outdir_path>/indel/mergedBams/NA11931.bam'
	touch <outdir_path>/indel/mergedBams/NA11931.bam.OK

<outdir_path>/indel/mergedBams/NA11918.bam.OK: | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/umake/bams/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in <gotcloud_root>/test/umake/bams/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out <outdir_path>/indel/mergedBams/NA11918.bam'
	touch <outdir_path>/indel/mergedBams/NA11918.bam.OK

<outdir_path>/indel/mergedBams/NA12043.bam.OK: | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/bam mergeBam --in <gotcloud_root>/test/umake/bams/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in <gotcloud_root>/test/umake/bams/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out <outdir_path>/indel/mergedBams/NA12043.bam'
	touch <outdir_path>/indel/mergedBams/NA12043.bam.OK

indel_mergeBam: <outdir_path>/indel/mergedBams/NA12045.bam.OK <outdir_path>/indel/mergedBams/NA12249.bam.OK <outdir_path>/indel/mergedBams/NA11931.bam.OK <outdir_path>/indel/mergedBams/NA11918.bam.OK <outdir_path>/indel/mergedBams/NA12043.bam.OK

<outdir_path>/indel/mergedBams/NA12045.bam.bai.OK: <outdir_path>/indel/mergedBams/NA12045.bam.OK | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/indel/mergedBams/NA12045.bam 2> <outdir_path>/indel/mergedBams/NA12045.bam.bai.log'
	touch <outdir_path>/indel/mergedBams/NA12045.bam.bai.OK

<outdir_path>/indel/mergedBams/NA12249.bam.bai.OK: <outdir_path>/indel/mergedBams/NA12249.bam.OK | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/indel/mergedBams/NA12249.bam 2> <outdir_path>/indel/mergedBams/NA12249.bam.bai.log'
	touch <outdir_path>/indel/mergedBams/NA12249.bam.bai.OK

<outdir_path>/indel/mergedBams/NA11931.bam.bai.OK: <outdir_path>/indel/mergedBams/NA11931.bam.OK | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/indel/mergedBams/NA11931.bam 2> <outdir_path>/indel/mergedBams/NA11931.bam.bai.log'
	touch <outdir_path>/indel/mergedBams/NA11931.bam.bai.OK

<outdir_path>/indel/mergedBams/NA11918.bam.bai.OK: <outdir_path>/indel/mergedBams/NA11918.bam.OK | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/indel/mergedBams/NA11918.bam 2> <outdir_path>/indel/mergedBams/NA11918.bam.bai.log'
	touch <outdir_path>/indel/mergedBams/NA11918.bam.bai.OK

<outdir_path>/indel/mergedBams/NA12043.bam.bai.OK: <outdir_path>/indel/mergedBams/NA12043.bam.OK | <outdir_path>/indel/mergedBams/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/samtools index <outdir_path>/indel/mergedBams/NA12043.bam 2> <outdir_path>/indel/mergedBams/NA12043.bam.bai.log'
	touch <outdir_path>/indel/mergedBams/NA12043.bam.bai.OK

indel_indexMBam: <outdir_path>/indel/mergedBams/NA12045.bam.bai.OK <outdir_path>/indel/mergedBams/NA12249.bam.bai.OK <outdir_path>/indel/mergedBams/NA11931.bam.bai.OK <outdir_path>/indel/mergedBams/NA11918.bam.bai.OK <outdir_path>/indel/mergedBams/NA12043.bam.bai.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12272  2> <outdir_path>/indel/indelvcf/NA12272/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12272/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12272/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12004  2> <outdir_path>/indel/indelvcf/NA12004/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12004/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12004/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11994  2> <outdir_path>/indel/indelvcf/NA11994/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11994/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11994/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12749  2> <outdir_path>/indel/indelvcf/NA12749/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12749/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12749/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA10847  2> <outdir_path>/indel/indelvcf/NA10847/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA10847/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf 2> <outdir_path>/indel/indelvcf/NA10847/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12716  2> <outdir_path>/indel/indelvcf/NA12716/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12716/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12716/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12829  2> <outdir_path>/indel/indelvcf/NA12829/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12829/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12829/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12275  2> <outdir_path>/indel/indelvcf/NA12275/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12275/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12275/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12750  2> <outdir_path>/indel/indelvcf/NA12750/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12750/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12750/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12348  2> <outdir_path>/indel/indelvcf/NA12348/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12348/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12348/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12347  2> <outdir_path>/indel/indelvcf/NA12347/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12347/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12347/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12003  2> <outdir_path>/indel/indelvcf/NA12003/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12003/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12003/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12286  2> <outdir_path>/indel/indelvcf/NA12286/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12286/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12286/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11829  2> <outdir_path>/indel/indelvcf/NA11829/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11829/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11829/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07357  2> <outdir_path>/indel/indelvcf/NA07357/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA07357/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07357/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12144  2> <outdir_path>/indel/indelvcf/NA12144/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12144/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12144/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12812  2> <outdir_path>/indel/indelvcf/NA12812/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12812/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12812/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12718  2> <outdir_path>/indel/indelvcf/NA12718/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12718/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12718/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12777  2> <outdir_path>/indel/indelvcf/NA12777/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12777/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12777/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12872  2> <outdir_path>/indel/indelvcf/NA12872/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12872/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12872/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12751  2> <outdir_path>/indel/indelvcf/NA12751/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12751/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12751/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12717  2> <outdir_path>/indel/indelvcf/NA12717/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12717/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12717/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07051  2> <outdir_path>/indel/indelvcf/NA07051/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA07051/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07051/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11992  2> <outdir_path>/indel/indelvcf/NA11992/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11992/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11992/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12058  2> <outdir_path>/indel/indelvcf/NA12058/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12058/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12058/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12889  2> <outdir_path>/indel/indelvcf/NA12889/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12889/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12889/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12400  2> <outdir_path>/indel/indelvcf/NA12400/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12400/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12400/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12778  2> <outdir_path>/indel/indelvcf/NA12778/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12778/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12778/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12154  2> <outdir_path>/indel/indelvcf/NA12154/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12154/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12154/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11932  2> <outdir_path>/indel/indelvcf/NA11932/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11932/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11932/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06986  2> <outdir_path>/indel/indelvcf/NA06986/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA06986/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06986/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07056  2> <outdir_path>/indel/indelvcf/NA07056/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA07056/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07056/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12046  2> <outdir_path>/indel/indelvcf/NA12046/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12046/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12046/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12342  2> <outdir_path>/indel/indelvcf/NA12342/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12342/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12342/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06984  2> <outdir_path>/indel/indelvcf/NA06984/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA06984/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06984/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12273  2> <outdir_path>/indel/indelvcf/NA12273/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12273/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12273/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12748  2> <outdir_path>/indel/indelvcf/NA12748/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12748/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12748/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12814  2> <outdir_path>/indel/indelvcf/NA12814/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12814/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12814/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12546  2> <outdir_path>/indel/indelvcf/NA12546/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12546/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12546/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12827  2> <outdir_path>/indel/indelvcf/NA12827/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12827/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12827/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12489  2> <outdir_path>/indel/indelvcf/NA12489/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12489/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12489/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12283  2> <outdir_path>/indel/indelvcf/NA12283/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12283/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12283/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11919  2> <outdir_path>/indel/indelvcf/NA11919/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11919/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11919/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11995  2> <outdir_path>/indel/indelvcf/NA11995/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11995/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11995/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07000  2> <outdir_path>/indel/indelvcf/NA07000/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA07000/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07000/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA10851  2> <outdir_path>/indel/indelvcf/NA10851/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA10851/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf 2> <outdir_path>/indel/indelvcf/NA10851/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12341  2> <outdir_path>/indel/indelvcf/NA12341/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12341/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12341/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11892  2> <outdir_path>/indel/indelvcf/NA11892/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11892/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11892/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12383  2> <outdir_path>/indel/indelvcf/NA12383/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12383/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12383/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06994  2> <outdir_path>/indel/indelvcf/NA06994/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA06994/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06994/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12006  2> <outdir_path>/indel/indelvcf/NA12006/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12006/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12006/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11993  2> <outdir_path>/indel/indelvcf/NA11993/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11993/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11993/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12413  2> <outdir_path>/indel/indelvcf/NA12413/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12413/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12413/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11920  2> <outdir_path>/indel/indelvcf/NA11920/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11920/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11920/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.OK: | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <gotcloud_root>/test/umake/bams/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12874  2> <outdir_path>/indel/indelvcf/NA12874/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12874/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12874/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.OK

singleBamDiscover: <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.OK: <outdir_path>/indel/mergedBams/NA12045.bam.bai.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <outdir_path>/indel/mergedBams/NA12045.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12045  2> <outdir_path>/indel/indelvcf/NA12045/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12045/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12045/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.OK: <outdir_path>/indel/mergedBams/NA12249.bam.bai.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <outdir_path>/indel/mergedBams/NA12249.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12249  2> <outdir_path>/indel/indelvcf/NA12249/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12249/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12249/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.OK: <outdir_path>/indel/mergedBams/NA11931.bam.bai.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <outdir_path>/indel/mergedBams/NA11931.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11931  2> <outdir_path>/indel/indelvcf/NA11931/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11931/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11931/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.OK: <outdir_path>/indel/mergedBams/NA11918.bam.bai.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <outdir_path>/indel/mergedBams/NA11918.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11918  2> <outdir_path>/indel/indelvcf/NA11918/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA11918/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11918/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.OK: <outdir_path>/indel/mergedBams/NA12043.bam.bai.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt discover -b <outdir_path>/indel/mergedBams/NA12043.bam -o + -v indels -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12043  2> <outdir_path>/indel/indelvcf/NA12043/discover.log | <gotcloud_root>/bin/vt normalize + -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> <outdir_path>/indel/indelvcf/NA12043/normalize.log | <gotcloud_root>/bin/vt mergedups + -o <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12043/mergedups.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.OK

multiBamDiscover: <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf 2> <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf 2> <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf 2> <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf 2> <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf 2> <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.OK | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf 2> <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.csi.OK

indexD: <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.csi.OK

<outdir_path>/indel/aux/all.sites.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.sites.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.sites.bcf.csi.OK | <outdir_path>/indel/aux/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt merge_candidate_variants -L <outdir_path>/indel/aux/candidate_vcf_files.txt -o <outdir_path>/indel/aux/all.sites.20.bcf -i 20 2> <outdir_path>/indel/aux/all.sites.20.bcf.log'
	touch <outdir_path>/indel/aux/all.sites.20.bcf.OK

merge: <outdir_path>/indel/aux/all.sites.20.bcf.OK

<outdir_path>/indel/aux/all.sites.20.bcf.csi.OK: <outdir_path>/indel/aux/all.sites.20.bcf.OK | <outdir_path>/indel/aux/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/aux/all.sites.20.bcf 2> <outdir_path>/indel/aux/all.sites.20.bcf.csi.log'
	touch <outdir_path>/indel/aux/all.sites.20.bcf.csi.OK

indexM: <outdir_path>/indel/aux/all.sites.20.bcf.csi.OK

<outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/all.sites.20.bcf.OK <outdir_path>/indel/aux/all.sites.20.bcf.csi.OK | <outdir_path>/indel/aux/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt construct_probes <outdir_path>/indel/aux/all.sites.20.bcf -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -o <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf -i 20:20000001-40000000 2> <outdir_path>/indel/aux/probes.20.20000001.40000000.log'
	touch <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK

probes: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK

<outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK | <outdir_path>/indel/aux/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK

indexP: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12272 -o <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12272/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12004 -o <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12004/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11994 -o <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11994/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12749 -o <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12749/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA10847 -o <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA10847/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12716 -o <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12716/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12829 -o <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12829/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12275 -o <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12275/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12750 -o <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12750/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12348 -o <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12348/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12347 -o <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12347/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12003 -o <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12003/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12286 -o <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12286/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11829 -o <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11829/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07357 -o <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07357/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12144 -o <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12144/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12812 -o <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12812/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12718 -o <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12718/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12777 -o <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12777/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12872 -o <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12872/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12751 -o <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12751/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12717 -o <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12717/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07051 -o <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07051/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11992 -o <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11992/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12058 -o <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12058/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12889 -o <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12889/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12400 -o <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12400/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12778 -o <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12778/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12154 -o <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12154/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11932 -o <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11932/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06986 -o <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06986/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07056 -o <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07056/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12046 -o <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12046/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12342 -o <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12342/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06984 -o <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06984/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12273 -o <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12273/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12748 -o <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12748/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12814 -o <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12814/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12546 -o <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12546/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12827 -o <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12827/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12489 -o <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12489/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12283 -o <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12283/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11919 -o <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11919/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11995 -o <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11995/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA07000 -o <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07000/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA10851 -o <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA10851/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12341 -o <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12341/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11892 -o <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11892/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12383 -o <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12383/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA06994 -o <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06994/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12006 -o <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12006/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11993 -o <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11993/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12413 -o <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12413/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11920 -o <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11920/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <gotcloud_root>/test/umake/bams/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12874 -o <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12874/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK

singleBamGenotype: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/mergedBams/NA12045.bam.bai.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <outdir_path>/indel/mergedBams/NA12045.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12045 -o <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12045/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/mergedBams/NA12249.bam.bai.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <outdir_path>/indel/mergedBams/NA12249.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12249 -o <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12249/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/mergedBams/NA11931.bam.bai.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <outdir_path>/indel/mergedBams/NA11931.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11931 -o <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11931/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/mergedBams/NA11918.bam.bai.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <outdir_path>/indel/mergedBams/NA11918.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA11918 -o <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11918/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK: <outdir_path>/indel/mergedBams/NA12043.bam.bai.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.OK <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf.csi.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt genotype -b <outdir_path>/indel/mergedBams/NA12043.bam -r <gotcloud_root>/test/chr20Ref/human_g1k_v37_chr20.fa -s NA12043 -o <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 <outdir_path>/indel/aux/probes.sites.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12043/genotype.20.20000001.40000000.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK

multiBamGenotype: <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf 2> <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK

indexG: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12272/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12004/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11994/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12749/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA10847/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12716/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12829/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12275/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12750/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12348/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12347/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12003/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12286/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11829/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07357/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12144/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12045/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12812/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12718/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12777/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12872/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12751/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12717/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07051/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12249/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11992/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12058/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12889/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12400/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12778/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12154/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11932/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11931/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06986/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07056/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12046/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12342/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06984/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12273/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12748/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12814/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12546/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12827/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12489/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12283/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11919/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11995/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07000/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA10851/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11918/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12341/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11892/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12383/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06994/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12006/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12043/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11993/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12413/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11920/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat -L <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.list.txt -o <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12874/concat.20.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.OK

concatG: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.OK

<outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12272/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12004/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12749/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA10847/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12716/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12275/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12750/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12348/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12347/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12003/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12286/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11829/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA07357/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12144/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12045/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12812/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12718/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12777/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12872/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12751/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12717/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA07051/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12249/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11992/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12058/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12889/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12400/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12778/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12154/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11932/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11931/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA06986/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA07056/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12046/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12342/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA06984/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12273/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12748/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12814/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12546/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12827/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12489/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12283/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11919/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11995/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA07000/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA10851/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11918/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12341/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11892/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12383/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA06994/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12006/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12043/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11993/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12413/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA11920/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.csi.OK: <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.OK | <outdir_path>/indel/indelvcf/NA12874/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf 2> <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.csi.log'
	touch <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.csi.OK

indexCG: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.csi.OK

<outdir_path>/indel/final/merge/all.genotypes.20.bcf.OK: <outdir_path>/indel/indelvcf/NA12272/NA12272.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12004/NA12004.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11994/NA11994.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12749/NA12749.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10847/NA10847.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12716/NA12716.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12829/NA12829.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12275/NA12275.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12750/NA12750.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12348/NA12348.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12347/NA12347.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12003/NA12003.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12286/NA12286.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11829/NA11829.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07357/NA07357.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12144/NA12144.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12045/NA12045.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12812/NA12812.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12718/NA12718.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12777/NA12777.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12872/NA12872.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12751/NA12751.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12717/NA12717.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07051/NA07051.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12249/NA12249.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11992/NA11992.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12058/NA12058.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12889/NA12889.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12400/NA12400.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12778/NA12778.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12154/NA12154.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11932/NA11932.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11931/NA11931.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06986/NA06986.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07056/NA07056.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12046/NA12046.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12342/NA12342.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06984/NA06984.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12273/NA12273.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12748/NA12748.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12814/NA12814.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12546/NA12546.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12827/NA12827.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12489/NA12489.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12283/NA12283.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11919/NA11919.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11995/NA11995.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA07000/NA07000.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA10851/NA10851.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11918/NA11918.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12341/NA12341.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11892/NA11892.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12383/NA12383.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA06994/NA06994.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12006/NA12006.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12043/NA12043.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11993/NA11993.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12413/NA12413.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA11920/NA11920.genotypesConcat.20.bcf.csi.OK <outdir_path>/indel/indelvcf/NA12874/NA12874.genotypesConcat.20.bcf.csi.OK | <outdir_path>/indel/final/merge/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt merge -L <outdir_path>/indel/aux/merge.20.vcf.list.txt -o + | <gotcloud_root>/bin/vt compute_features + -o + 2> <outdir_path>/indel/final/merge/compute_features.20.log | <gotcloud_root>/bin/vt remove_overlap + -o <outdir_path>/indel/final/merge/all.genotypes.20.bcf 2> <outdir_path>/indel/final/merge/remove_overlap.20.log'
	touch <outdir_path>/indel/final/merge/all.genotypes.20.bcf.OK

mergeG: <outdir_path>/indel/final/merge/all.genotypes.20.bcf.OK

<outdir_path>/indel/final/merge/all.genotypes.20.bcf.csi.OK: <outdir_path>/indel/final/merge/all.genotypes.20.bcf.OK | <outdir_path>/indel/final/merge/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/final/merge/all.genotypes.20.bcf 2> <outdir_path>/indel/final/merge/all.genotypes.20.bcf.csi.log'
	touch <outdir_path>/indel/final/merge/all.genotypes.20.bcf.csi.OK

indexMG: <outdir_path>/indel/final/merge/all.genotypes.20.bcf.csi.OK

<outdir_path>/indel/final/all.genotypes.vcf.gz.OK: <outdir_path>/indel/final/merge/all.genotypes.20.bcf.OK | <outdir_path>/indel/final/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt concat <outdir_path>/indel/final/merge/all.genotypes.20.bcf -o <outdir_path>/indel/final/all.genotypes.vcf.gz 2> <outdir_path>/indel/final/concat.log'
	touch <outdir_path>/indel/final/all.genotypes.vcf.gz.OK

concat: <outdir_path>/indel/final/all.genotypes.vcf.gz.OK

<outdir_path>/indel/final/all.genotypes.vcf.gz.tbi.OK: <outdir_path>/indel/final/all.genotypes.vcf.gz.OK | <outdir_path>/indel/final/
	<gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/jobfiles local '<gotcloud_root>/bin/vt index <outdir_path>/indel/final/all.genotypes.vcf.gz 2> <outdir_path>/indel/final/all.genotypes.vcf.gz.tbi.log'
	touch <outdir_path>/indel/final/all.genotypes.vcf.gz.tbi.OK

indexC: <outdir_path>/indel/final/all.genotypes.vcf.gz.tbi.OK

<outdir_path>/indel/aux/:
	mkdir -p <outdir_path>/indel/aux/

<outdir_path>/indel/final/:
	mkdir -p <outdir_path>/indel/final/

<outdir_path>/indel/final/merge/:
	mkdir -p <outdir_path>/indel/final/merge/

<outdir_path>/indel/indelvcf/NA06984/:
	mkdir -p <outdir_path>/indel/indelvcf/NA06984/

<outdir_path>/indel/indelvcf/NA06986/:
	mkdir -p <outdir_path>/indel/indelvcf/NA06986/

<outdir_path>/indel/indelvcf/NA06994/:
	mkdir -p <outdir_path>/indel/indelvcf/NA06994/

<outdir_path>/indel/indelvcf/NA07000/:
	mkdir -p <outdir_path>/indel/indelvcf/NA07000/

<outdir_path>/indel/indelvcf/NA07051/:
	mkdir -p <outdir_path>/indel/indelvcf/NA07051/

<outdir_path>/indel/indelvcf/NA07056/:
	mkdir -p <outdir_path>/indel/indelvcf/NA07056/

<outdir_path>/indel/indelvcf/NA07357/:
	mkdir -p <outdir_path>/indel/indelvcf/NA07357/

<outdir_path>/indel/indelvcf/NA10847/:
	mkdir -p <outdir_path>/indel/indelvcf/NA10847/

<outdir_path>/indel/indelvcf/NA10851/:
	mkdir -p <outdir_path>/indel/indelvcf/NA10851/

<outdir_path>/indel/indelvcf/NA11829/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11829/

<outdir_path>/indel/indelvcf/NA11892/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11892/

<outdir_path>/indel/indelvcf/NA11918/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11918/

<outdir_path>/indel/indelvcf/NA11919/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11919/

<outdir_path>/indel/indelvcf/NA11920/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11920/

<outdir_path>/indel/indelvcf/NA11931/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11931/

<outdir_path>/indel/indelvcf/NA11932/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11932/

<outdir_path>/indel/indelvcf/NA11992/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11992/

<outdir_path>/indel/indelvcf/NA11993/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11993/

<outdir_path>/indel/indelvcf/NA11994/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11994/

<outdir_path>/indel/indelvcf/NA11995/:
	mkdir -p <outdir_path>/indel/indelvcf/NA11995/

<outdir_path>/indel/indelvcf/NA12003/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12003/

<outdir_path>/indel/indelvcf/NA12004/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12004/

<outdir_path>/indel/indelvcf/NA12006/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12006/

<outdir_path>/indel/indelvcf/NA12043/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12043/

<outdir_path>/indel/indelvcf/NA12045/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12045/

<outdir_path>/indel/indelvcf/NA12046/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12046/

<outdir_path>/indel/indelvcf/NA12058/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12058/

<outdir_path>/indel/indelvcf/NA12144/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12144/

<outdir_path>/indel/indelvcf/NA12154/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12154/

<outdir_path>/indel/indelvcf/NA12249/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12249/

<outdir_path>/indel/indelvcf/NA12272/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12272/

<outdir_path>/indel/indelvcf/NA12273/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12273/

<outdir_path>/indel/indelvcf/NA12275/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12275/

<outdir_path>/indel/indelvcf/NA12283/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12283/

<outdir_path>/indel/indelvcf/NA12286/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12286/

<outdir_path>/indel/indelvcf/NA12341/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12341/

<outdir_path>/indel/indelvcf/NA12342/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12342/

<outdir_path>/indel/indelvcf/NA12347/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12347/

<outdir_path>/indel/indelvcf/NA12348/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12348/

<outdir_path>/indel/indelvcf/NA12383/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12383/

<outdir_path>/indel/indelvcf/NA12400/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12400/

<outdir_path>/indel/indelvcf/NA12413/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12413/

<outdir_path>/indel/indelvcf/NA12489/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12489/

<outdir_path>/indel/indelvcf/NA12546/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12546/

<outdir_path>/indel/indelvcf/NA12716/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12716/

<outdir_path>/indel/indelvcf/NA12717/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12717/

<outdir_path>/indel/indelvcf/NA12718/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12718/

<outdir_path>/indel/indelvcf/NA12748/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12748/

<outdir_path>/indel/indelvcf/NA12749/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12749/

<outdir_path>/indel/indelvcf/NA12750/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12750/

<outdir_path>/indel/indelvcf/NA12751/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12751/

<outdir_path>/indel/indelvcf/NA12777/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12777/

<outdir_path>/indel/indelvcf/NA12778/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12778/

<outdir_path>/indel/indelvcf/NA12812/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12812/

<outdir_path>/indel/indelvcf/NA12814/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12814/

<outdir_path>/indel/indelvcf/NA12827/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12827/

<outdir_path>/indel/indelvcf/NA12829/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12829/

<outdir_path>/indel/indelvcf/NA12872/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12872/

<outdir_path>/indel/indelvcf/NA12874/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12874/

<outdir_path>/indel/indelvcf/NA12889/:
	mkdir -p <outdir_path>/indel/indelvcf/NA12889/

<outdir_path>/indel/mergedBams/:
	mkdir -p <outdir_path>/indel/mergedBams/

