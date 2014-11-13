.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

all: mergeBam indexBam singleBamDiscover multiBamDiscover indexD merge indexM probes indexP singleBamGenotype multiBamGenotype indexG mergeG indexMG concat indexC
mergedBams/NA12045.bam.OK: | mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/umake/bams/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in test/umake/bams/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out mergedBams/NA12045.bam'
	touch mergedBams/NA12045.bam.OK

mergedBams/NA12249.bam.OK: | mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/umake/bams/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in test/umake/bams/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out mergedBams/NA12249.bam'
	touch mergedBams/NA12249.bam.OK

mergedBams/NA11931.bam.OK: | mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/umake/bams/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in test/umake/bams/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out mergedBams/NA11931.bam'
	touch mergedBams/NA11931.bam.OK

mergedBams/NA11918.bam.OK: | mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/umake/bams/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in test/umake/bams/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out mergedBams/NA11918.bam'
	touch mergedBams/NA11918.bam.OK

mergedBams/NA12043.bam.OK: | mergedBams/
	scripts/runcluster.pl local 'bin/bam mergeBam --in test/umake/bams/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --in test/umake/bams/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam --out mergedBams/NA12043.bam'
	touch mergedBams/NA12043.bam.OK

mergeBam: mergedBams/NA12045.bam.OK mergedBams/NA12249.bam.OK mergedBams/NA11931.bam.OK mergedBams/NA11918.bam.OK mergedBams/NA12043.bam.OK

mergedBams/NA12045.bam.bai.OK: mergedBams/NA12045.bam.OK | mergedBams/
	scripts/runcluster.pl local 'bin/samtools index mergedBams/NA12045.bam 2> mergedBams/NA12045.bam.bai.log'
	touch mergedBams/NA12045.bam.bai.OK

mergedBams/NA12249.bam.bai.OK: mergedBams/NA12249.bam.OK | mergedBams/
	scripts/runcluster.pl local 'bin/samtools index mergedBams/NA12249.bam 2> mergedBams/NA12249.bam.bai.log'
	touch mergedBams/NA12249.bam.bai.OK

mergedBams/NA11931.bam.bai.OK: mergedBams/NA11931.bam.OK | mergedBams/
	scripts/runcluster.pl local 'bin/samtools index mergedBams/NA11931.bam 2> mergedBams/NA11931.bam.bai.log'
	touch mergedBams/NA11931.bam.bai.OK

mergedBams/NA11918.bam.bai.OK: mergedBams/NA11918.bam.OK | mergedBams/
	scripts/runcluster.pl local 'bin/samtools index mergedBams/NA11918.bam 2> mergedBams/NA11918.bam.bai.log'
	touch mergedBams/NA11918.bam.bai.OK

mergedBams/NA12043.bam.bai.OK: mergedBams/NA12043.bam.OK | mergedBams/
	scripts/runcluster.pl local 'bin/samtools index mergedBams/NA12043.bam 2> mergedBams/NA12043.bam.bai.log'
	touch mergedBams/NA12043.bam.bai.OK

indexBam: mergedBams/NA12045.bam.bai.OK mergedBams/NA12249.bam.bai.OK mergedBams/NA11931.bam.bai.OK mergedBams/NA11918.bam.bai.OK mergedBams/NA12043.bam.bai.OK

indelvcf/NA12272/NA12272.sites.bcf.OK: | indelvcf/NA12272/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12272  2> indelvcf/NA12272/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12272/normalize.log | vt mergedups + -o indelvcf/NA12272/NA12272.sites.bcf 2> indelvcf/NA12272/mergedups.log'
	touch indelvcf/NA12272/NA12272.sites.bcf.OK

indelvcf/NA12004/NA12004.sites.bcf.OK: | indelvcf/NA12004/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12004  2> indelvcf/NA12004/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12004/normalize.log | vt mergedups + -o indelvcf/NA12004/NA12004.sites.bcf 2> indelvcf/NA12004/mergedups.log'
	touch indelvcf/NA12004/NA12004.sites.bcf.OK

indelvcf/NA11994/NA11994.sites.bcf.OK: | indelvcf/NA11994/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11994  2> indelvcf/NA11994/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11994/normalize.log | vt mergedups + -o indelvcf/NA11994/NA11994.sites.bcf 2> indelvcf/NA11994/mergedups.log'
	touch indelvcf/NA11994/NA11994.sites.bcf.OK

indelvcf/NA12749/NA12749.sites.bcf.OK: | indelvcf/NA12749/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12749  2> indelvcf/NA12749/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12749/normalize.log | vt mergedups + -o indelvcf/NA12749/NA12749.sites.bcf 2> indelvcf/NA12749/mergedups.log'
	touch indelvcf/NA12749/NA12749.sites.bcf.OK

indelvcf/NA10847/NA10847.sites.bcf.OK: | indelvcf/NA10847/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA10847  2> indelvcf/NA10847/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA10847/normalize.log | vt mergedups + -o indelvcf/NA10847/NA10847.sites.bcf 2> indelvcf/NA10847/mergedups.log'
	touch indelvcf/NA10847/NA10847.sites.bcf.OK

indelvcf/NA12716/NA12716.sites.bcf.OK: | indelvcf/NA12716/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12716  2> indelvcf/NA12716/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12716/normalize.log | vt mergedups + -o indelvcf/NA12716/NA12716.sites.bcf 2> indelvcf/NA12716/mergedups.log'
	touch indelvcf/NA12716/NA12716.sites.bcf.OK

indelvcf/NA12829/NA12829.sites.bcf.OK: | indelvcf/NA12829/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12829  2> indelvcf/NA12829/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12829/normalize.log | vt mergedups + -o indelvcf/NA12829/NA12829.sites.bcf 2> indelvcf/NA12829/mergedups.log'
	touch indelvcf/NA12829/NA12829.sites.bcf.OK

indelvcf/NA12275/NA12275.sites.bcf.OK: | indelvcf/NA12275/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12275  2> indelvcf/NA12275/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12275/normalize.log | vt mergedups + -o indelvcf/NA12275/NA12275.sites.bcf 2> indelvcf/NA12275/mergedups.log'
	touch indelvcf/NA12275/NA12275.sites.bcf.OK

indelvcf/NA12750/NA12750.sites.bcf.OK: | indelvcf/NA12750/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12750  2> indelvcf/NA12750/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12750/normalize.log | vt mergedups + -o indelvcf/NA12750/NA12750.sites.bcf 2> indelvcf/NA12750/mergedups.log'
	touch indelvcf/NA12750/NA12750.sites.bcf.OK

indelvcf/NA12348/NA12348.sites.bcf.OK: | indelvcf/NA12348/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12348  2> indelvcf/NA12348/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12348/normalize.log | vt mergedups + -o indelvcf/NA12348/NA12348.sites.bcf 2> indelvcf/NA12348/mergedups.log'
	touch indelvcf/NA12348/NA12348.sites.bcf.OK

indelvcf/NA12347/NA12347.sites.bcf.OK: | indelvcf/NA12347/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12347  2> indelvcf/NA12347/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12347/normalize.log | vt mergedups + -o indelvcf/NA12347/NA12347.sites.bcf 2> indelvcf/NA12347/mergedups.log'
	touch indelvcf/NA12347/NA12347.sites.bcf.OK

indelvcf/NA12003/NA12003.sites.bcf.OK: | indelvcf/NA12003/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12003  2> indelvcf/NA12003/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12003/normalize.log | vt mergedups + -o indelvcf/NA12003/NA12003.sites.bcf 2> indelvcf/NA12003/mergedups.log'
	touch indelvcf/NA12003/NA12003.sites.bcf.OK

indelvcf/NA12286/NA12286.sites.bcf.OK: | indelvcf/NA12286/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12286  2> indelvcf/NA12286/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12286/normalize.log | vt mergedups + -o indelvcf/NA12286/NA12286.sites.bcf 2> indelvcf/NA12286/mergedups.log'
	touch indelvcf/NA12286/NA12286.sites.bcf.OK

indelvcf/NA11829/NA11829.sites.bcf.OK: | indelvcf/NA11829/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11829  2> indelvcf/NA11829/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11829/normalize.log | vt mergedups + -o indelvcf/NA11829/NA11829.sites.bcf 2> indelvcf/NA11829/mergedups.log'
	touch indelvcf/NA11829/NA11829.sites.bcf.OK

indelvcf/NA07357/NA07357.sites.bcf.OK: | indelvcf/NA07357/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07357  2> indelvcf/NA07357/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA07357/normalize.log | vt mergedups + -o indelvcf/NA07357/NA07357.sites.bcf 2> indelvcf/NA07357/mergedups.log'
	touch indelvcf/NA07357/NA07357.sites.bcf.OK

indelvcf/NA12144/NA12144.sites.bcf.OK: | indelvcf/NA12144/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12144  2> indelvcf/NA12144/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12144/normalize.log | vt mergedups + -o indelvcf/NA12144/NA12144.sites.bcf 2> indelvcf/NA12144/mergedups.log'
	touch indelvcf/NA12144/NA12144.sites.bcf.OK

indelvcf/NA12812/NA12812.sites.bcf.OK: | indelvcf/NA12812/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12812  2> indelvcf/NA12812/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12812/normalize.log | vt mergedups + -o indelvcf/NA12812/NA12812.sites.bcf 2> indelvcf/NA12812/mergedups.log'
	touch indelvcf/NA12812/NA12812.sites.bcf.OK

indelvcf/NA12718/NA12718.sites.bcf.OK: | indelvcf/NA12718/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12718  2> indelvcf/NA12718/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12718/normalize.log | vt mergedups + -o indelvcf/NA12718/NA12718.sites.bcf 2> indelvcf/NA12718/mergedups.log'
	touch indelvcf/NA12718/NA12718.sites.bcf.OK

indelvcf/NA12777/NA12777.sites.bcf.OK: | indelvcf/NA12777/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12777  2> indelvcf/NA12777/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12777/normalize.log | vt mergedups + -o indelvcf/NA12777/NA12777.sites.bcf 2> indelvcf/NA12777/mergedups.log'
	touch indelvcf/NA12777/NA12777.sites.bcf.OK

indelvcf/NA12872/NA12872.sites.bcf.OK: | indelvcf/NA12872/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12872  2> indelvcf/NA12872/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12872/normalize.log | vt mergedups + -o indelvcf/NA12872/NA12872.sites.bcf 2> indelvcf/NA12872/mergedups.log'
	touch indelvcf/NA12872/NA12872.sites.bcf.OK

indelvcf/NA12751/NA12751.sites.bcf.OK: | indelvcf/NA12751/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12751  2> indelvcf/NA12751/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12751/normalize.log | vt mergedups + -o indelvcf/NA12751/NA12751.sites.bcf 2> indelvcf/NA12751/mergedups.log'
	touch indelvcf/NA12751/NA12751.sites.bcf.OK

indelvcf/NA12717/NA12717.sites.bcf.OK: | indelvcf/NA12717/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12717  2> indelvcf/NA12717/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12717/normalize.log | vt mergedups + -o indelvcf/NA12717/NA12717.sites.bcf 2> indelvcf/NA12717/mergedups.log'
	touch indelvcf/NA12717/NA12717.sites.bcf.OK

indelvcf/NA07051/NA07051.sites.bcf.OK: | indelvcf/NA07051/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07051  2> indelvcf/NA07051/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA07051/normalize.log | vt mergedups + -o indelvcf/NA07051/NA07051.sites.bcf 2> indelvcf/NA07051/mergedups.log'
	touch indelvcf/NA07051/NA07051.sites.bcf.OK

indelvcf/NA11992/NA11992.sites.bcf.OK: | indelvcf/NA11992/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11992  2> indelvcf/NA11992/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11992/normalize.log | vt mergedups + -o indelvcf/NA11992/NA11992.sites.bcf 2> indelvcf/NA11992/mergedups.log'
	touch indelvcf/NA11992/NA11992.sites.bcf.OK

indelvcf/NA12058/NA12058.sites.bcf.OK: | indelvcf/NA12058/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12058  2> indelvcf/NA12058/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12058/normalize.log | vt mergedups + -o indelvcf/NA12058/NA12058.sites.bcf 2> indelvcf/NA12058/mergedups.log'
	touch indelvcf/NA12058/NA12058.sites.bcf.OK

indelvcf/NA12889/NA12889.sites.bcf.OK: | indelvcf/NA12889/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12889  2> indelvcf/NA12889/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12889/normalize.log | vt mergedups + -o indelvcf/NA12889/NA12889.sites.bcf 2> indelvcf/NA12889/mergedups.log'
	touch indelvcf/NA12889/NA12889.sites.bcf.OK

indelvcf/NA12400/NA12400.sites.bcf.OK: | indelvcf/NA12400/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12400  2> indelvcf/NA12400/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12400/normalize.log | vt mergedups + -o indelvcf/NA12400/NA12400.sites.bcf 2> indelvcf/NA12400/mergedups.log'
	touch indelvcf/NA12400/NA12400.sites.bcf.OK

indelvcf/NA12778/NA12778.sites.bcf.OK: | indelvcf/NA12778/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12778  2> indelvcf/NA12778/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12778/normalize.log | vt mergedups + -o indelvcf/NA12778/NA12778.sites.bcf 2> indelvcf/NA12778/mergedups.log'
	touch indelvcf/NA12778/NA12778.sites.bcf.OK

indelvcf/NA12154/NA12154.sites.bcf.OK: | indelvcf/NA12154/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12154  2> indelvcf/NA12154/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12154/normalize.log | vt mergedups + -o indelvcf/NA12154/NA12154.sites.bcf 2> indelvcf/NA12154/mergedups.log'
	touch indelvcf/NA12154/NA12154.sites.bcf.OK

indelvcf/NA11932/NA11932.sites.bcf.OK: | indelvcf/NA11932/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11932  2> indelvcf/NA11932/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11932/normalize.log | vt mergedups + -o indelvcf/NA11932/NA11932.sites.bcf 2> indelvcf/NA11932/mergedups.log'
	touch indelvcf/NA11932/NA11932.sites.bcf.OK

indelvcf/NA06986/NA06986.sites.bcf.OK: | indelvcf/NA06986/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06986  2> indelvcf/NA06986/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA06986/normalize.log | vt mergedups + -o indelvcf/NA06986/NA06986.sites.bcf 2> indelvcf/NA06986/mergedups.log'
	touch indelvcf/NA06986/NA06986.sites.bcf.OK

indelvcf/NA07056/NA07056.sites.bcf.OK: | indelvcf/NA07056/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07056  2> indelvcf/NA07056/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA07056/normalize.log | vt mergedups + -o indelvcf/NA07056/NA07056.sites.bcf 2> indelvcf/NA07056/mergedups.log'
	touch indelvcf/NA07056/NA07056.sites.bcf.OK

indelvcf/NA12046/NA12046.sites.bcf.OK: | indelvcf/NA12046/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12046  2> indelvcf/NA12046/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12046/normalize.log | vt mergedups + -o indelvcf/NA12046/NA12046.sites.bcf 2> indelvcf/NA12046/mergedups.log'
	touch indelvcf/NA12046/NA12046.sites.bcf.OK

indelvcf/NA12342/NA12342.sites.bcf.OK: | indelvcf/NA12342/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12342  2> indelvcf/NA12342/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12342/normalize.log | vt mergedups + -o indelvcf/NA12342/NA12342.sites.bcf 2> indelvcf/NA12342/mergedups.log'
	touch indelvcf/NA12342/NA12342.sites.bcf.OK

indelvcf/NA06984/NA06984.sites.bcf.OK: | indelvcf/NA06984/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06984  2> indelvcf/NA06984/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA06984/normalize.log | vt mergedups + -o indelvcf/NA06984/NA06984.sites.bcf 2> indelvcf/NA06984/mergedups.log'
	touch indelvcf/NA06984/NA06984.sites.bcf.OK

indelvcf/NA12273/NA12273.sites.bcf.OK: | indelvcf/NA12273/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12273  2> indelvcf/NA12273/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12273/normalize.log | vt mergedups + -o indelvcf/NA12273/NA12273.sites.bcf 2> indelvcf/NA12273/mergedups.log'
	touch indelvcf/NA12273/NA12273.sites.bcf.OK

indelvcf/NA12748/NA12748.sites.bcf.OK: | indelvcf/NA12748/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12748  2> indelvcf/NA12748/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12748/normalize.log | vt mergedups + -o indelvcf/NA12748/NA12748.sites.bcf 2> indelvcf/NA12748/mergedups.log'
	touch indelvcf/NA12748/NA12748.sites.bcf.OK

indelvcf/NA12814/NA12814.sites.bcf.OK: | indelvcf/NA12814/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12814  2> indelvcf/NA12814/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12814/normalize.log | vt mergedups + -o indelvcf/NA12814/NA12814.sites.bcf 2> indelvcf/NA12814/mergedups.log'
	touch indelvcf/NA12814/NA12814.sites.bcf.OK

indelvcf/NA12546/NA12546.sites.bcf.OK: | indelvcf/NA12546/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12546  2> indelvcf/NA12546/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12546/normalize.log | vt mergedups + -o indelvcf/NA12546/NA12546.sites.bcf 2> indelvcf/NA12546/mergedups.log'
	touch indelvcf/NA12546/NA12546.sites.bcf.OK

indelvcf/NA12827/NA12827.sites.bcf.OK: | indelvcf/NA12827/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12827  2> indelvcf/NA12827/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12827/normalize.log | vt mergedups + -o indelvcf/NA12827/NA12827.sites.bcf 2> indelvcf/NA12827/mergedups.log'
	touch indelvcf/NA12827/NA12827.sites.bcf.OK

indelvcf/NA12489/NA12489.sites.bcf.OK: | indelvcf/NA12489/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12489  2> indelvcf/NA12489/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12489/normalize.log | vt mergedups + -o indelvcf/NA12489/NA12489.sites.bcf 2> indelvcf/NA12489/mergedups.log'
	touch indelvcf/NA12489/NA12489.sites.bcf.OK

indelvcf/NA12283/NA12283.sites.bcf.OK: | indelvcf/NA12283/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12283  2> indelvcf/NA12283/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12283/normalize.log | vt mergedups + -o indelvcf/NA12283/NA12283.sites.bcf 2> indelvcf/NA12283/mergedups.log'
	touch indelvcf/NA12283/NA12283.sites.bcf.OK

indelvcf/NA11919/NA11919.sites.bcf.OK: | indelvcf/NA11919/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11919  2> indelvcf/NA11919/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11919/normalize.log | vt mergedups + -o indelvcf/NA11919/NA11919.sites.bcf 2> indelvcf/NA11919/mergedups.log'
	touch indelvcf/NA11919/NA11919.sites.bcf.OK

indelvcf/NA11995/NA11995.sites.bcf.OK: | indelvcf/NA11995/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11995  2> indelvcf/NA11995/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11995/normalize.log | vt mergedups + -o indelvcf/NA11995/NA11995.sites.bcf 2> indelvcf/NA11995/mergedups.log'
	touch indelvcf/NA11995/NA11995.sites.bcf.OK

indelvcf/NA07000/NA07000.sites.bcf.OK: | indelvcf/NA07000/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07000  2> indelvcf/NA07000/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA07000/normalize.log | vt mergedups + -o indelvcf/NA07000/NA07000.sites.bcf 2> indelvcf/NA07000/mergedups.log'
	touch indelvcf/NA07000/NA07000.sites.bcf.OK

indelvcf/NA10851/NA10851.sites.bcf.OK: | indelvcf/NA10851/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA10851  2> indelvcf/NA10851/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA10851/normalize.log | vt mergedups + -o indelvcf/NA10851/NA10851.sites.bcf 2> indelvcf/NA10851/mergedups.log'
	touch indelvcf/NA10851/NA10851.sites.bcf.OK

indelvcf/NA12341/NA12341.sites.bcf.OK: | indelvcf/NA12341/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12341  2> indelvcf/NA12341/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12341/normalize.log | vt mergedups + -o indelvcf/NA12341/NA12341.sites.bcf 2> indelvcf/NA12341/mergedups.log'
	touch indelvcf/NA12341/NA12341.sites.bcf.OK

indelvcf/NA11892/NA11892.sites.bcf.OK: | indelvcf/NA11892/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11892  2> indelvcf/NA11892/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11892/normalize.log | vt mergedups + -o indelvcf/NA11892/NA11892.sites.bcf 2> indelvcf/NA11892/mergedups.log'
	touch indelvcf/NA11892/NA11892.sites.bcf.OK

indelvcf/NA12383/NA12383.sites.bcf.OK: | indelvcf/NA12383/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12383  2> indelvcf/NA12383/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12383/normalize.log | vt mergedups + -o indelvcf/NA12383/NA12383.sites.bcf 2> indelvcf/NA12383/mergedups.log'
	touch indelvcf/NA12383/NA12383.sites.bcf.OK

indelvcf/NA06994/NA06994.sites.bcf.OK: | indelvcf/NA06994/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06994  2> indelvcf/NA06994/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA06994/normalize.log | vt mergedups + -o indelvcf/NA06994/NA06994.sites.bcf 2> indelvcf/NA06994/mergedups.log'
	touch indelvcf/NA06994/NA06994.sites.bcf.OK

indelvcf/NA12006/NA12006.sites.bcf.OK: | indelvcf/NA12006/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12006  2> indelvcf/NA12006/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12006/normalize.log | vt mergedups + -o indelvcf/NA12006/NA12006.sites.bcf 2> indelvcf/NA12006/mergedups.log'
	touch indelvcf/NA12006/NA12006.sites.bcf.OK

indelvcf/NA11993/NA11993.sites.bcf.OK: | indelvcf/NA11993/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11993  2> indelvcf/NA11993/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11993/normalize.log | vt mergedups + -o indelvcf/NA11993/NA11993.sites.bcf 2> indelvcf/NA11993/mergedups.log'
	touch indelvcf/NA11993/NA11993.sites.bcf.OK

indelvcf/NA12413/NA12413.sites.bcf.OK: | indelvcf/NA12413/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12413  2> indelvcf/NA12413/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12413/normalize.log | vt mergedups + -o indelvcf/NA12413/NA12413.sites.bcf 2> indelvcf/NA12413/mergedups.log'
	touch indelvcf/NA12413/NA12413.sites.bcf.OK

indelvcf/NA11920/NA11920.sites.bcf.OK: | indelvcf/NA11920/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11920  2> indelvcf/NA11920/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11920/normalize.log | vt mergedups + -o indelvcf/NA11920/NA11920.sites.bcf 2> indelvcf/NA11920/mergedups.log'
	touch indelvcf/NA11920/NA11920.sites.bcf.OK

indelvcf/NA12874/NA12874.sites.bcf.OK: | indelvcf/NA12874/
	scripts/runcluster.pl local 'vt discover -b test/umake/bams/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12874  2> indelvcf/NA12874/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12874/normalize.log | vt mergedups + -o indelvcf/NA12874/NA12874.sites.bcf 2> indelvcf/NA12874/mergedups.log'
	touch indelvcf/NA12874/NA12874.sites.bcf.OK

singleBamDiscover: indelvcf/NA12272/NA12272.sites.bcf.OK indelvcf/NA12004/NA12004.sites.bcf.OK indelvcf/NA11994/NA11994.sites.bcf.OK indelvcf/NA12749/NA12749.sites.bcf.OK indelvcf/NA10847/NA10847.sites.bcf.OK indelvcf/NA12716/NA12716.sites.bcf.OK indelvcf/NA12829/NA12829.sites.bcf.OK indelvcf/NA12275/NA12275.sites.bcf.OK indelvcf/NA12750/NA12750.sites.bcf.OK indelvcf/NA12348/NA12348.sites.bcf.OK indelvcf/NA12347/NA12347.sites.bcf.OK indelvcf/NA12003/NA12003.sites.bcf.OK indelvcf/NA12286/NA12286.sites.bcf.OK indelvcf/NA11829/NA11829.sites.bcf.OK indelvcf/NA07357/NA07357.sites.bcf.OK indelvcf/NA12144/NA12144.sites.bcf.OK indelvcf/NA12812/NA12812.sites.bcf.OK indelvcf/NA12718/NA12718.sites.bcf.OK indelvcf/NA12777/NA12777.sites.bcf.OK indelvcf/NA12872/NA12872.sites.bcf.OK indelvcf/NA12751/NA12751.sites.bcf.OK indelvcf/NA12717/NA12717.sites.bcf.OK indelvcf/NA07051/NA07051.sites.bcf.OK indelvcf/NA11992/NA11992.sites.bcf.OK indelvcf/NA12058/NA12058.sites.bcf.OK indelvcf/NA12889/NA12889.sites.bcf.OK indelvcf/NA12400/NA12400.sites.bcf.OK indelvcf/NA12778/NA12778.sites.bcf.OK indelvcf/NA12154/NA12154.sites.bcf.OK indelvcf/NA11932/NA11932.sites.bcf.OK indelvcf/NA06986/NA06986.sites.bcf.OK indelvcf/NA07056/NA07056.sites.bcf.OK indelvcf/NA12046/NA12046.sites.bcf.OK indelvcf/NA12342/NA12342.sites.bcf.OK indelvcf/NA06984/NA06984.sites.bcf.OK indelvcf/NA12273/NA12273.sites.bcf.OK indelvcf/NA12748/NA12748.sites.bcf.OK indelvcf/NA12814/NA12814.sites.bcf.OK indelvcf/NA12546/NA12546.sites.bcf.OK indelvcf/NA12827/NA12827.sites.bcf.OK indelvcf/NA12489/NA12489.sites.bcf.OK indelvcf/NA12283/NA12283.sites.bcf.OK indelvcf/NA11919/NA11919.sites.bcf.OK indelvcf/NA11995/NA11995.sites.bcf.OK indelvcf/NA07000/NA07000.sites.bcf.OK indelvcf/NA10851/NA10851.sites.bcf.OK indelvcf/NA12341/NA12341.sites.bcf.OK indelvcf/NA11892/NA11892.sites.bcf.OK indelvcf/NA12383/NA12383.sites.bcf.OK indelvcf/NA06994/NA06994.sites.bcf.OK indelvcf/NA12006/NA12006.sites.bcf.OK indelvcf/NA11993/NA11993.sites.bcf.OK indelvcf/NA12413/NA12413.sites.bcf.OK indelvcf/NA11920/NA11920.sites.bcf.OK indelvcf/NA12874/NA12874.sites.bcf.OK

indelvcf/NA12045/NA12045.sites.bcf.OK: mergedBams/NA12045.bam.bai.OK | indelvcf/NA12045/
	scripts/runcluster.pl local 'vt discover -b mergedBams/NA12045.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12045  2> indelvcf/NA12045/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12045/normalize.log | vt mergedups + -o indelvcf/NA12045/NA12045.sites.bcf 2> indelvcf/NA12045/mergedups.log'
	touch indelvcf/NA12045/NA12045.sites.bcf.OK

indelvcf/NA12249/NA12249.sites.bcf.OK: mergedBams/NA12249.bam.bai.OK | indelvcf/NA12249/
	scripts/runcluster.pl local 'vt discover -b mergedBams/NA12249.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12249  2> indelvcf/NA12249/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12249/normalize.log | vt mergedups + -o indelvcf/NA12249/NA12249.sites.bcf 2> indelvcf/NA12249/mergedups.log'
	touch indelvcf/NA12249/NA12249.sites.bcf.OK

indelvcf/NA11931/NA11931.sites.bcf.OK: mergedBams/NA11931.bam.bai.OK | indelvcf/NA11931/
	scripts/runcluster.pl local 'vt discover -b mergedBams/NA11931.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11931  2> indelvcf/NA11931/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11931/normalize.log | vt mergedups + -o indelvcf/NA11931/NA11931.sites.bcf 2> indelvcf/NA11931/mergedups.log'
	touch indelvcf/NA11931/NA11931.sites.bcf.OK

indelvcf/NA11918/NA11918.sites.bcf.OK: mergedBams/NA11918.bam.bai.OK | indelvcf/NA11918/
	scripts/runcluster.pl local 'vt discover -b mergedBams/NA11918.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11918  2> indelvcf/NA11918/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA11918/normalize.log | vt mergedups + -o indelvcf/NA11918/NA11918.sites.bcf 2> indelvcf/NA11918/mergedups.log'
	touch indelvcf/NA11918/NA11918.sites.bcf.OK

indelvcf/NA12043/NA12043.sites.bcf.OK: mergedBams/NA12043.bam.bai.OK | indelvcf/NA12043/
	scripts/runcluster.pl local 'vt discover -b mergedBams/NA12043.bam -o + -v indels -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12043  2> indelvcf/NA12043/discover.log | vt normalize + -r test/chr20Ref/human_g1k_v37_chr20.fa -o + 2> indelvcf/NA12043/normalize.log | vt mergedups + -o indelvcf/NA12043/NA12043.sites.bcf 2> indelvcf/NA12043/mergedups.log'
	touch indelvcf/NA12043/NA12043.sites.bcf.OK

multiBamDiscover: indelvcf/NA12045/NA12045.sites.bcf.OK indelvcf/NA12249/NA12249.sites.bcf.OK indelvcf/NA11931/NA11931.sites.bcf.OK indelvcf/NA11918/NA11918.sites.bcf.OK indelvcf/NA12043/NA12043.sites.bcf.OK

indelvcf/NA12272/NA12272.sites.bcf.csi.OK: indelvcf/NA12272/NA12272.sites.bcf.OK | indelvcf/NA12272/
	scripts/runcluster.pl local 'vt index indelvcf/NA12272/NA12272.sites.bcf 2> indelvcf/NA12272/NA12272.sites.bcf.csi.log'
	touch indelvcf/NA12272/NA12272.sites.bcf.csi.OK

indelvcf/NA12004/NA12004.sites.bcf.csi.OK: indelvcf/NA12004/NA12004.sites.bcf.OK | indelvcf/NA12004/
	scripts/runcluster.pl local 'vt index indelvcf/NA12004/NA12004.sites.bcf 2> indelvcf/NA12004/NA12004.sites.bcf.csi.log'
	touch indelvcf/NA12004/NA12004.sites.bcf.csi.OK

indelvcf/NA11994/NA11994.sites.bcf.csi.OK: indelvcf/NA11994/NA11994.sites.bcf.OK | indelvcf/NA11994/
	scripts/runcluster.pl local 'vt index indelvcf/NA11994/NA11994.sites.bcf 2> indelvcf/NA11994/NA11994.sites.bcf.csi.log'
	touch indelvcf/NA11994/NA11994.sites.bcf.csi.OK

indelvcf/NA12749/NA12749.sites.bcf.csi.OK: indelvcf/NA12749/NA12749.sites.bcf.OK | indelvcf/NA12749/
	scripts/runcluster.pl local 'vt index indelvcf/NA12749/NA12749.sites.bcf 2> indelvcf/NA12749/NA12749.sites.bcf.csi.log'
	touch indelvcf/NA12749/NA12749.sites.bcf.csi.OK

indelvcf/NA10847/NA10847.sites.bcf.csi.OK: indelvcf/NA10847/NA10847.sites.bcf.OK | indelvcf/NA10847/
	scripts/runcluster.pl local 'vt index indelvcf/NA10847/NA10847.sites.bcf 2> indelvcf/NA10847/NA10847.sites.bcf.csi.log'
	touch indelvcf/NA10847/NA10847.sites.bcf.csi.OK

indelvcf/NA12716/NA12716.sites.bcf.csi.OK: indelvcf/NA12716/NA12716.sites.bcf.OK | indelvcf/NA12716/
	scripts/runcluster.pl local 'vt index indelvcf/NA12716/NA12716.sites.bcf 2> indelvcf/NA12716/NA12716.sites.bcf.csi.log'
	touch indelvcf/NA12716/NA12716.sites.bcf.csi.OK

indelvcf/NA12829/NA12829.sites.bcf.csi.OK: indelvcf/NA12829/NA12829.sites.bcf.OK | indelvcf/NA12829/
	scripts/runcluster.pl local 'vt index indelvcf/NA12829/NA12829.sites.bcf 2> indelvcf/NA12829/NA12829.sites.bcf.csi.log'
	touch indelvcf/NA12829/NA12829.sites.bcf.csi.OK

indelvcf/NA12275/NA12275.sites.bcf.csi.OK: indelvcf/NA12275/NA12275.sites.bcf.OK | indelvcf/NA12275/
	scripts/runcluster.pl local 'vt index indelvcf/NA12275/NA12275.sites.bcf 2> indelvcf/NA12275/NA12275.sites.bcf.csi.log'
	touch indelvcf/NA12275/NA12275.sites.bcf.csi.OK

indelvcf/NA12750/NA12750.sites.bcf.csi.OK: indelvcf/NA12750/NA12750.sites.bcf.OK | indelvcf/NA12750/
	scripts/runcluster.pl local 'vt index indelvcf/NA12750/NA12750.sites.bcf 2> indelvcf/NA12750/NA12750.sites.bcf.csi.log'
	touch indelvcf/NA12750/NA12750.sites.bcf.csi.OK

indelvcf/NA12348/NA12348.sites.bcf.csi.OK: indelvcf/NA12348/NA12348.sites.bcf.OK | indelvcf/NA12348/
	scripts/runcluster.pl local 'vt index indelvcf/NA12348/NA12348.sites.bcf 2> indelvcf/NA12348/NA12348.sites.bcf.csi.log'
	touch indelvcf/NA12348/NA12348.sites.bcf.csi.OK

indelvcf/NA12347/NA12347.sites.bcf.csi.OK: indelvcf/NA12347/NA12347.sites.bcf.OK | indelvcf/NA12347/
	scripts/runcluster.pl local 'vt index indelvcf/NA12347/NA12347.sites.bcf 2> indelvcf/NA12347/NA12347.sites.bcf.csi.log'
	touch indelvcf/NA12347/NA12347.sites.bcf.csi.OK

indelvcf/NA12003/NA12003.sites.bcf.csi.OK: indelvcf/NA12003/NA12003.sites.bcf.OK | indelvcf/NA12003/
	scripts/runcluster.pl local 'vt index indelvcf/NA12003/NA12003.sites.bcf 2> indelvcf/NA12003/NA12003.sites.bcf.csi.log'
	touch indelvcf/NA12003/NA12003.sites.bcf.csi.OK

indelvcf/NA12286/NA12286.sites.bcf.csi.OK: indelvcf/NA12286/NA12286.sites.bcf.OK | indelvcf/NA12286/
	scripts/runcluster.pl local 'vt index indelvcf/NA12286/NA12286.sites.bcf 2> indelvcf/NA12286/NA12286.sites.bcf.csi.log'
	touch indelvcf/NA12286/NA12286.sites.bcf.csi.OK

indelvcf/NA11829/NA11829.sites.bcf.csi.OK: indelvcf/NA11829/NA11829.sites.bcf.OK | indelvcf/NA11829/
	scripts/runcluster.pl local 'vt index indelvcf/NA11829/NA11829.sites.bcf 2> indelvcf/NA11829/NA11829.sites.bcf.csi.log'
	touch indelvcf/NA11829/NA11829.sites.bcf.csi.OK

indelvcf/NA07357/NA07357.sites.bcf.csi.OK: indelvcf/NA07357/NA07357.sites.bcf.OK | indelvcf/NA07357/
	scripts/runcluster.pl local 'vt index indelvcf/NA07357/NA07357.sites.bcf 2> indelvcf/NA07357/NA07357.sites.bcf.csi.log'
	touch indelvcf/NA07357/NA07357.sites.bcf.csi.OK

indelvcf/NA12144/NA12144.sites.bcf.csi.OK: indelvcf/NA12144/NA12144.sites.bcf.OK | indelvcf/NA12144/
	scripts/runcluster.pl local 'vt index indelvcf/NA12144/NA12144.sites.bcf 2> indelvcf/NA12144/NA12144.sites.bcf.csi.log'
	touch indelvcf/NA12144/NA12144.sites.bcf.csi.OK

indelvcf/NA12045/NA12045.sites.bcf.csi.OK: indelvcf/NA12045/NA12045.sites.bcf.OK | indelvcf/NA12045/
	scripts/runcluster.pl local 'vt index indelvcf/NA12045/NA12045.sites.bcf 2> indelvcf/NA12045/NA12045.sites.bcf.csi.log'
	touch indelvcf/NA12045/NA12045.sites.bcf.csi.OK

indelvcf/NA12812/NA12812.sites.bcf.csi.OK: indelvcf/NA12812/NA12812.sites.bcf.OK | indelvcf/NA12812/
	scripts/runcluster.pl local 'vt index indelvcf/NA12812/NA12812.sites.bcf 2> indelvcf/NA12812/NA12812.sites.bcf.csi.log'
	touch indelvcf/NA12812/NA12812.sites.bcf.csi.OK

indelvcf/NA12718/NA12718.sites.bcf.csi.OK: indelvcf/NA12718/NA12718.sites.bcf.OK | indelvcf/NA12718/
	scripts/runcluster.pl local 'vt index indelvcf/NA12718/NA12718.sites.bcf 2> indelvcf/NA12718/NA12718.sites.bcf.csi.log'
	touch indelvcf/NA12718/NA12718.sites.bcf.csi.OK

indelvcf/NA12777/NA12777.sites.bcf.csi.OK: indelvcf/NA12777/NA12777.sites.bcf.OK | indelvcf/NA12777/
	scripts/runcluster.pl local 'vt index indelvcf/NA12777/NA12777.sites.bcf 2> indelvcf/NA12777/NA12777.sites.bcf.csi.log'
	touch indelvcf/NA12777/NA12777.sites.bcf.csi.OK

indelvcf/NA12872/NA12872.sites.bcf.csi.OK: indelvcf/NA12872/NA12872.sites.bcf.OK | indelvcf/NA12872/
	scripts/runcluster.pl local 'vt index indelvcf/NA12872/NA12872.sites.bcf 2> indelvcf/NA12872/NA12872.sites.bcf.csi.log'
	touch indelvcf/NA12872/NA12872.sites.bcf.csi.OK

indelvcf/NA12751/NA12751.sites.bcf.csi.OK: indelvcf/NA12751/NA12751.sites.bcf.OK | indelvcf/NA12751/
	scripts/runcluster.pl local 'vt index indelvcf/NA12751/NA12751.sites.bcf 2> indelvcf/NA12751/NA12751.sites.bcf.csi.log'
	touch indelvcf/NA12751/NA12751.sites.bcf.csi.OK

indelvcf/NA12717/NA12717.sites.bcf.csi.OK: indelvcf/NA12717/NA12717.sites.bcf.OK | indelvcf/NA12717/
	scripts/runcluster.pl local 'vt index indelvcf/NA12717/NA12717.sites.bcf 2> indelvcf/NA12717/NA12717.sites.bcf.csi.log'
	touch indelvcf/NA12717/NA12717.sites.bcf.csi.OK

indelvcf/NA07051/NA07051.sites.bcf.csi.OK: indelvcf/NA07051/NA07051.sites.bcf.OK | indelvcf/NA07051/
	scripts/runcluster.pl local 'vt index indelvcf/NA07051/NA07051.sites.bcf 2> indelvcf/NA07051/NA07051.sites.bcf.csi.log'
	touch indelvcf/NA07051/NA07051.sites.bcf.csi.OK

indelvcf/NA12249/NA12249.sites.bcf.csi.OK: indelvcf/NA12249/NA12249.sites.bcf.OK | indelvcf/NA12249/
	scripts/runcluster.pl local 'vt index indelvcf/NA12249/NA12249.sites.bcf 2> indelvcf/NA12249/NA12249.sites.bcf.csi.log'
	touch indelvcf/NA12249/NA12249.sites.bcf.csi.OK

indelvcf/NA11992/NA11992.sites.bcf.csi.OK: indelvcf/NA11992/NA11992.sites.bcf.OK | indelvcf/NA11992/
	scripts/runcluster.pl local 'vt index indelvcf/NA11992/NA11992.sites.bcf 2> indelvcf/NA11992/NA11992.sites.bcf.csi.log'
	touch indelvcf/NA11992/NA11992.sites.bcf.csi.OK

indelvcf/NA12058/NA12058.sites.bcf.csi.OK: indelvcf/NA12058/NA12058.sites.bcf.OK | indelvcf/NA12058/
	scripts/runcluster.pl local 'vt index indelvcf/NA12058/NA12058.sites.bcf 2> indelvcf/NA12058/NA12058.sites.bcf.csi.log'
	touch indelvcf/NA12058/NA12058.sites.bcf.csi.OK

indelvcf/NA12889/NA12889.sites.bcf.csi.OK: indelvcf/NA12889/NA12889.sites.bcf.OK | indelvcf/NA12889/
	scripts/runcluster.pl local 'vt index indelvcf/NA12889/NA12889.sites.bcf 2> indelvcf/NA12889/NA12889.sites.bcf.csi.log'
	touch indelvcf/NA12889/NA12889.sites.bcf.csi.OK

indelvcf/NA12400/NA12400.sites.bcf.csi.OK: indelvcf/NA12400/NA12400.sites.bcf.OK | indelvcf/NA12400/
	scripts/runcluster.pl local 'vt index indelvcf/NA12400/NA12400.sites.bcf 2> indelvcf/NA12400/NA12400.sites.bcf.csi.log'
	touch indelvcf/NA12400/NA12400.sites.bcf.csi.OK

indelvcf/NA12778/NA12778.sites.bcf.csi.OK: indelvcf/NA12778/NA12778.sites.bcf.OK | indelvcf/NA12778/
	scripts/runcluster.pl local 'vt index indelvcf/NA12778/NA12778.sites.bcf 2> indelvcf/NA12778/NA12778.sites.bcf.csi.log'
	touch indelvcf/NA12778/NA12778.sites.bcf.csi.OK

indelvcf/NA12154/NA12154.sites.bcf.csi.OK: indelvcf/NA12154/NA12154.sites.bcf.OK | indelvcf/NA12154/
	scripts/runcluster.pl local 'vt index indelvcf/NA12154/NA12154.sites.bcf 2> indelvcf/NA12154/NA12154.sites.bcf.csi.log'
	touch indelvcf/NA12154/NA12154.sites.bcf.csi.OK

indelvcf/NA11932/NA11932.sites.bcf.csi.OK: indelvcf/NA11932/NA11932.sites.bcf.OK | indelvcf/NA11932/
	scripts/runcluster.pl local 'vt index indelvcf/NA11932/NA11932.sites.bcf 2> indelvcf/NA11932/NA11932.sites.bcf.csi.log'
	touch indelvcf/NA11932/NA11932.sites.bcf.csi.OK

indelvcf/NA11931/NA11931.sites.bcf.csi.OK: indelvcf/NA11931/NA11931.sites.bcf.OK | indelvcf/NA11931/
	scripts/runcluster.pl local 'vt index indelvcf/NA11931/NA11931.sites.bcf 2> indelvcf/NA11931/NA11931.sites.bcf.csi.log'
	touch indelvcf/NA11931/NA11931.sites.bcf.csi.OK

indelvcf/NA06986/NA06986.sites.bcf.csi.OK: indelvcf/NA06986/NA06986.sites.bcf.OK | indelvcf/NA06986/
	scripts/runcluster.pl local 'vt index indelvcf/NA06986/NA06986.sites.bcf 2> indelvcf/NA06986/NA06986.sites.bcf.csi.log'
	touch indelvcf/NA06986/NA06986.sites.bcf.csi.OK

indelvcf/NA07056/NA07056.sites.bcf.csi.OK: indelvcf/NA07056/NA07056.sites.bcf.OK | indelvcf/NA07056/
	scripts/runcluster.pl local 'vt index indelvcf/NA07056/NA07056.sites.bcf 2> indelvcf/NA07056/NA07056.sites.bcf.csi.log'
	touch indelvcf/NA07056/NA07056.sites.bcf.csi.OK

indelvcf/NA12046/NA12046.sites.bcf.csi.OK: indelvcf/NA12046/NA12046.sites.bcf.OK | indelvcf/NA12046/
	scripts/runcluster.pl local 'vt index indelvcf/NA12046/NA12046.sites.bcf 2> indelvcf/NA12046/NA12046.sites.bcf.csi.log'
	touch indelvcf/NA12046/NA12046.sites.bcf.csi.OK

indelvcf/NA12342/NA12342.sites.bcf.csi.OK: indelvcf/NA12342/NA12342.sites.bcf.OK | indelvcf/NA12342/
	scripts/runcluster.pl local 'vt index indelvcf/NA12342/NA12342.sites.bcf 2> indelvcf/NA12342/NA12342.sites.bcf.csi.log'
	touch indelvcf/NA12342/NA12342.sites.bcf.csi.OK

indelvcf/NA06984/NA06984.sites.bcf.csi.OK: indelvcf/NA06984/NA06984.sites.bcf.OK | indelvcf/NA06984/
	scripts/runcluster.pl local 'vt index indelvcf/NA06984/NA06984.sites.bcf 2> indelvcf/NA06984/NA06984.sites.bcf.csi.log'
	touch indelvcf/NA06984/NA06984.sites.bcf.csi.OK

indelvcf/NA12273/NA12273.sites.bcf.csi.OK: indelvcf/NA12273/NA12273.sites.bcf.OK | indelvcf/NA12273/
	scripts/runcluster.pl local 'vt index indelvcf/NA12273/NA12273.sites.bcf 2> indelvcf/NA12273/NA12273.sites.bcf.csi.log'
	touch indelvcf/NA12273/NA12273.sites.bcf.csi.OK

indelvcf/NA12748/NA12748.sites.bcf.csi.OK: indelvcf/NA12748/NA12748.sites.bcf.OK | indelvcf/NA12748/
	scripts/runcluster.pl local 'vt index indelvcf/NA12748/NA12748.sites.bcf 2> indelvcf/NA12748/NA12748.sites.bcf.csi.log'
	touch indelvcf/NA12748/NA12748.sites.bcf.csi.OK

indelvcf/NA12814/NA12814.sites.bcf.csi.OK: indelvcf/NA12814/NA12814.sites.bcf.OK | indelvcf/NA12814/
	scripts/runcluster.pl local 'vt index indelvcf/NA12814/NA12814.sites.bcf 2> indelvcf/NA12814/NA12814.sites.bcf.csi.log'
	touch indelvcf/NA12814/NA12814.sites.bcf.csi.OK

indelvcf/NA12546/NA12546.sites.bcf.csi.OK: indelvcf/NA12546/NA12546.sites.bcf.OK | indelvcf/NA12546/
	scripts/runcluster.pl local 'vt index indelvcf/NA12546/NA12546.sites.bcf 2> indelvcf/NA12546/NA12546.sites.bcf.csi.log'
	touch indelvcf/NA12546/NA12546.sites.bcf.csi.OK

indelvcf/NA12827/NA12827.sites.bcf.csi.OK: indelvcf/NA12827/NA12827.sites.bcf.OK | indelvcf/NA12827/
	scripts/runcluster.pl local 'vt index indelvcf/NA12827/NA12827.sites.bcf 2> indelvcf/NA12827/NA12827.sites.bcf.csi.log'
	touch indelvcf/NA12827/NA12827.sites.bcf.csi.OK

indelvcf/NA12489/NA12489.sites.bcf.csi.OK: indelvcf/NA12489/NA12489.sites.bcf.OK | indelvcf/NA12489/
	scripts/runcluster.pl local 'vt index indelvcf/NA12489/NA12489.sites.bcf 2> indelvcf/NA12489/NA12489.sites.bcf.csi.log'
	touch indelvcf/NA12489/NA12489.sites.bcf.csi.OK

indelvcf/NA12283/NA12283.sites.bcf.csi.OK: indelvcf/NA12283/NA12283.sites.bcf.OK | indelvcf/NA12283/
	scripts/runcluster.pl local 'vt index indelvcf/NA12283/NA12283.sites.bcf 2> indelvcf/NA12283/NA12283.sites.bcf.csi.log'
	touch indelvcf/NA12283/NA12283.sites.bcf.csi.OK

indelvcf/NA11919/NA11919.sites.bcf.csi.OK: indelvcf/NA11919/NA11919.sites.bcf.OK | indelvcf/NA11919/
	scripts/runcluster.pl local 'vt index indelvcf/NA11919/NA11919.sites.bcf 2> indelvcf/NA11919/NA11919.sites.bcf.csi.log'
	touch indelvcf/NA11919/NA11919.sites.bcf.csi.OK

indelvcf/NA11995/NA11995.sites.bcf.csi.OK: indelvcf/NA11995/NA11995.sites.bcf.OK | indelvcf/NA11995/
	scripts/runcluster.pl local 'vt index indelvcf/NA11995/NA11995.sites.bcf 2> indelvcf/NA11995/NA11995.sites.bcf.csi.log'
	touch indelvcf/NA11995/NA11995.sites.bcf.csi.OK

indelvcf/NA07000/NA07000.sites.bcf.csi.OK: indelvcf/NA07000/NA07000.sites.bcf.OK | indelvcf/NA07000/
	scripts/runcluster.pl local 'vt index indelvcf/NA07000/NA07000.sites.bcf 2> indelvcf/NA07000/NA07000.sites.bcf.csi.log'
	touch indelvcf/NA07000/NA07000.sites.bcf.csi.OK

indelvcf/NA10851/NA10851.sites.bcf.csi.OK: indelvcf/NA10851/NA10851.sites.bcf.OK | indelvcf/NA10851/
	scripts/runcluster.pl local 'vt index indelvcf/NA10851/NA10851.sites.bcf 2> indelvcf/NA10851/NA10851.sites.bcf.csi.log'
	touch indelvcf/NA10851/NA10851.sites.bcf.csi.OK

indelvcf/NA11918/NA11918.sites.bcf.csi.OK: indelvcf/NA11918/NA11918.sites.bcf.OK | indelvcf/NA11918/
	scripts/runcluster.pl local 'vt index indelvcf/NA11918/NA11918.sites.bcf 2> indelvcf/NA11918/NA11918.sites.bcf.csi.log'
	touch indelvcf/NA11918/NA11918.sites.bcf.csi.OK

indelvcf/NA12341/NA12341.sites.bcf.csi.OK: indelvcf/NA12341/NA12341.sites.bcf.OK | indelvcf/NA12341/
	scripts/runcluster.pl local 'vt index indelvcf/NA12341/NA12341.sites.bcf 2> indelvcf/NA12341/NA12341.sites.bcf.csi.log'
	touch indelvcf/NA12341/NA12341.sites.bcf.csi.OK

indelvcf/NA11892/NA11892.sites.bcf.csi.OK: indelvcf/NA11892/NA11892.sites.bcf.OK | indelvcf/NA11892/
	scripts/runcluster.pl local 'vt index indelvcf/NA11892/NA11892.sites.bcf 2> indelvcf/NA11892/NA11892.sites.bcf.csi.log'
	touch indelvcf/NA11892/NA11892.sites.bcf.csi.OK

indelvcf/NA12383/NA12383.sites.bcf.csi.OK: indelvcf/NA12383/NA12383.sites.bcf.OK | indelvcf/NA12383/
	scripts/runcluster.pl local 'vt index indelvcf/NA12383/NA12383.sites.bcf 2> indelvcf/NA12383/NA12383.sites.bcf.csi.log'
	touch indelvcf/NA12383/NA12383.sites.bcf.csi.OK

indelvcf/NA06994/NA06994.sites.bcf.csi.OK: indelvcf/NA06994/NA06994.sites.bcf.OK | indelvcf/NA06994/
	scripts/runcluster.pl local 'vt index indelvcf/NA06994/NA06994.sites.bcf 2> indelvcf/NA06994/NA06994.sites.bcf.csi.log'
	touch indelvcf/NA06994/NA06994.sites.bcf.csi.OK

indelvcf/NA12006/NA12006.sites.bcf.csi.OK: indelvcf/NA12006/NA12006.sites.bcf.OK | indelvcf/NA12006/
	scripts/runcluster.pl local 'vt index indelvcf/NA12006/NA12006.sites.bcf 2> indelvcf/NA12006/NA12006.sites.bcf.csi.log'
	touch indelvcf/NA12006/NA12006.sites.bcf.csi.OK

indelvcf/NA12043/NA12043.sites.bcf.csi.OK: indelvcf/NA12043/NA12043.sites.bcf.OK | indelvcf/NA12043/
	scripts/runcluster.pl local 'vt index indelvcf/NA12043/NA12043.sites.bcf 2> indelvcf/NA12043/NA12043.sites.bcf.csi.log'
	touch indelvcf/NA12043/NA12043.sites.bcf.csi.OK

indelvcf/NA11993/NA11993.sites.bcf.csi.OK: indelvcf/NA11993/NA11993.sites.bcf.OK | indelvcf/NA11993/
	scripts/runcluster.pl local 'vt index indelvcf/NA11993/NA11993.sites.bcf 2> indelvcf/NA11993/NA11993.sites.bcf.csi.log'
	touch indelvcf/NA11993/NA11993.sites.bcf.csi.OK

indelvcf/NA12413/NA12413.sites.bcf.csi.OK: indelvcf/NA12413/NA12413.sites.bcf.OK | indelvcf/NA12413/
	scripts/runcluster.pl local 'vt index indelvcf/NA12413/NA12413.sites.bcf 2> indelvcf/NA12413/NA12413.sites.bcf.csi.log'
	touch indelvcf/NA12413/NA12413.sites.bcf.csi.OK

indelvcf/NA11920/NA11920.sites.bcf.csi.OK: indelvcf/NA11920/NA11920.sites.bcf.OK | indelvcf/NA11920/
	scripts/runcluster.pl local 'vt index indelvcf/NA11920/NA11920.sites.bcf 2> indelvcf/NA11920/NA11920.sites.bcf.csi.log'
	touch indelvcf/NA11920/NA11920.sites.bcf.csi.OK

indelvcf/NA12874/NA12874.sites.bcf.csi.OK: indelvcf/NA12874/NA12874.sites.bcf.OK | indelvcf/NA12874/
	scripts/runcluster.pl local 'vt index indelvcf/NA12874/NA12874.sites.bcf 2> indelvcf/NA12874/NA12874.sites.bcf.csi.log'
	touch indelvcf/NA12874/NA12874.sites.bcf.csi.OK

indexD: indelvcf/NA12272/NA12272.sites.bcf.csi.OK indelvcf/NA12004/NA12004.sites.bcf.csi.OK indelvcf/NA11994/NA11994.sites.bcf.csi.OK indelvcf/NA12749/NA12749.sites.bcf.csi.OK indelvcf/NA10847/NA10847.sites.bcf.csi.OK indelvcf/NA12716/NA12716.sites.bcf.csi.OK indelvcf/NA12829/NA12829.sites.bcf.csi.OK indelvcf/NA12275/NA12275.sites.bcf.csi.OK indelvcf/NA12750/NA12750.sites.bcf.csi.OK indelvcf/NA12348/NA12348.sites.bcf.csi.OK indelvcf/NA12347/NA12347.sites.bcf.csi.OK indelvcf/NA12003/NA12003.sites.bcf.csi.OK indelvcf/NA12286/NA12286.sites.bcf.csi.OK indelvcf/NA11829/NA11829.sites.bcf.csi.OK indelvcf/NA07357/NA07357.sites.bcf.csi.OK indelvcf/NA12144/NA12144.sites.bcf.csi.OK indelvcf/NA12045/NA12045.sites.bcf.csi.OK indelvcf/NA12812/NA12812.sites.bcf.csi.OK indelvcf/NA12718/NA12718.sites.bcf.csi.OK indelvcf/NA12777/NA12777.sites.bcf.csi.OK indelvcf/NA12872/NA12872.sites.bcf.csi.OK indelvcf/NA12751/NA12751.sites.bcf.csi.OK indelvcf/NA12717/NA12717.sites.bcf.csi.OK indelvcf/NA07051/NA07051.sites.bcf.csi.OK indelvcf/NA12249/NA12249.sites.bcf.csi.OK indelvcf/NA11992/NA11992.sites.bcf.csi.OK indelvcf/NA12058/NA12058.sites.bcf.csi.OK indelvcf/NA12889/NA12889.sites.bcf.csi.OK indelvcf/NA12400/NA12400.sites.bcf.csi.OK indelvcf/NA12778/NA12778.sites.bcf.csi.OK indelvcf/NA12154/NA12154.sites.bcf.csi.OK indelvcf/NA11932/NA11932.sites.bcf.csi.OK indelvcf/NA11931/NA11931.sites.bcf.csi.OK indelvcf/NA06986/NA06986.sites.bcf.csi.OK indelvcf/NA07056/NA07056.sites.bcf.csi.OK indelvcf/NA12046/NA12046.sites.bcf.csi.OK indelvcf/NA12342/NA12342.sites.bcf.csi.OK indelvcf/NA06984/NA06984.sites.bcf.csi.OK indelvcf/NA12273/NA12273.sites.bcf.csi.OK indelvcf/NA12748/NA12748.sites.bcf.csi.OK indelvcf/NA12814/NA12814.sites.bcf.csi.OK indelvcf/NA12546/NA12546.sites.bcf.csi.OK indelvcf/NA12827/NA12827.sites.bcf.csi.OK indelvcf/NA12489/NA12489.sites.bcf.csi.OK indelvcf/NA12283/NA12283.sites.bcf.csi.OK indelvcf/NA11919/NA11919.sites.bcf.csi.OK indelvcf/NA11995/NA11995.sites.bcf.csi.OK indelvcf/NA07000/NA07000.sites.bcf.csi.OK indelvcf/NA10851/NA10851.sites.bcf.csi.OK indelvcf/NA11918/NA11918.sites.bcf.csi.OK indelvcf/NA12341/NA12341.sites.bcf.csi.OK indelvcf/NA11892/NA11892.sites.bcf.csi.OK indelvcf/NA12383/NA12383.sites.bcf.csi.OK indelvcf/NA06994/NA06994.sites.bcf.csi.OK indelvcf/NA12006/NA12006.sites.bcf.csi.OK indelvcf/NA12043/NA12043.sites.bcf.csi.OK indelvcf/NA11993/NA11993.sites.bcf.csi.OK indelvcf/NA12413/NA12413.sites.bcf.csi.OK indelvcf/NA11920/NA11920.sites.bcf.csi.OK indelvcf/NA12874/NA12874.sites.bcf.csi.OK

aux/all.sites.20.bcf.OK: indelvcf/NA12272/NA12272.sites.bcf.csi.OK indelvcf/NA12004/NA12004.sites.bcf.csi.OK indelvcf/NA11994/NA11994.sites.bcf.csi.OK indelvcf/NA12749/NA12749.sites.bcf.csi.OK indelvcf/NA10847/NA10847.sites.bcf.csi.OK indelvcf/NA12716/NA12716.sites.bcf.csi.OK indelvcf/NA12829/NA12829.sites.bcf.csi.OK indelvcf/NA12275/NA12275.sites.bcf.csi.OK indelvcf/NA12750/NA12750.sites.bcf.csi.OK indelvcf/NA12348/NA12348.sites.bcf.csi.OK indelvcf/NA12347/NA12347.sites.bcf.csi.OK indelvcf/NA12003/NA12003.sites.bcf.csi.OK indelvcf/NA12286/NA12286.sites.bcf.csi.OK indelvcf/NA11829/NA11829.sites.bcf.csi.OK indelvcf/NA07357/NA07357.sites.bcf.csi.OK indelvcf/NA12144/NA12144.sites.bcf.csi.OK indelvcf/NA12045/NA12045.sites.bcf.csi.OK indelvcf/NA12812/NA12812.sites.bcf.csi.OK indelvcf/NA12718/NA12718.sites.bcf.csi.OK indelvcf/NA12777/NA12777.sites.bcf.csi.OK indelvcf/NA12872/NA12872.sites.bcf.csi.OK indelvcf/NA12751/NA12751.sites.bcf.csi.OK indelvcf/NA12717/NA12717.sites.bcf.csi.OK indelvcf/NA07051/NA07051.sites.bcf.csi.OK indelvcf/NA12249/NA12249.sites.bcf.csi.OK indelvcf/NA11992/NA11992.sites.bcf.csi.OK indelvcf/NA12058/NA12058.sites.bcf.csi.OK indelvcf/NA12889/NA12889.sites.bcf.csi.OK indelvcf/NA12400/NA12400.sites.bcf.csi.OK indelvcf/NA12778/NA12778.sites.bcf.csi.OK indelvcf/NA12154/NA12154.sites.bcf.csi.OK indelvcf/NA11932/NA11932.sites.bcf.csi.OK indelvcf/NA11931/NA11931.sites.bcf.csi.OK indelvcf/NA06986/NA06986.sites.bcf.csi.OK indelvcf/NA07056/NA07056.sites.bcf.csi.OK indelvcf/NA12046/NA12046.sites.bcf.csi.OK indelvcf/NA12342/NA12342.sites.bcf.csi.OK indelvcf/NA06984/NA06984.sites.bcf.csi.OK indelvcf/NA12273/NA12273.sites.bcf.csi.OK indelvcf/NA12748/NA12748.sites.bcf.csi.OK indelvcf/NA12814/NA12814.sites.bcf.csi.OK indelvcf/NA12546/NA12546.sites.bcf.csi.OK indelvcf/NA12827/NA12827.sites.bcf.csi.OK indelvcf/NA12489/NA12489.sites.bcf.csi.OK indelvcf/NA12283/NA12283.sites.bcf.csi.OK indelvcf/NA11919/NA11919.sites.bcf.csi.OK indelvcf/NA11995/NA11995.sites.bcf.csi.OK indelvcf/NA07000/NA07000.sites.bcf.csi.OK indelvcf/NA10851/NA10851.sites.bcf.csi.OK indelvcf/NA11918/NA11918.sites.bcf.csi.OK indelvcf/NA12341/NA12341.sites.bcf.csi.OK indelvcf/NA11892/NA11892.sites.bcf.csi.OK indelvcf/NA12383/NA12383.sites.bcf.csi.OK indelvcf/NA06994/NA06994.sites.bcf.csi.OK indelvcf/NA12006/NA12006.sites.bcf.csi.OK indelvcf/NA12043/NA12043.sites.bcf.csi.OK indelvcf/NA11993/NA11993.sites.bcf.csi.OK indelvcf/NA12413/NA12413.sites.bcf.csi.OK indelvcf/NA11920/NA11920.sites.bcf.csi.OK indelvcf/NA12874/NA12874.sites.bcf.csi.OK | aux/
	scripts/runcluster.pl local 'vt merge_candidate_variants -L aux/candidate_vcf_files.txt -o aux/all.sites.20.bcf -i 20 2> aux/all.sites.20.bcf.log'
	touch aux/all.sites.20.bcf.OK

merge: aux/all.sites.20.bcf.OK

aux/all.sites.20.bcf.csi.OK: aux/all.sites.20.bcf.OK | aux/
	scripts/runcluster.pl local 'vt index aux/all.sites.20.bcf 2> aux/all.sites.20.bcf.csi.log'
	touch aux/all.sites.20.bcf.csi.OK

indexM: aux/all.sites.20.bcf.csi.OK

aux/probes.sites.20.20000001.40000000.bcf.OK: aux/all.sites.20.bcf.OK aux/all.sites.20.bcf.csi.OK | aux/
	scripts/runcluster.pl local 'vt construct_probes aux/all.sites.20.bcf -r test/chr20Ref/human_g1k_v37_chr20.fa -o aux/probes.sites.20.20000001.40000000.bcf -i 20:20000001-40000000 2> aux/probes.20.20000001.40000000.log'
	touch aux/probes.sites.20.20000001.40000000.bcf.OK

probes: aux/probes.sites.20.20000001.40000000.bcf.OK

aux/probes.sites.20.20000001.40000000.bcf.csi.OK: aux/probes.sites.20.20000001.40000000.bcf.OK | aux/
	scripts/runcluster.pl local 'vt index aux/probes.sites.20.20000001.40000000.bcf 2> aux/probes.sites.20.20000001.40000000.bcf.csi.log'
	touch aux/probes.sites.20.20000001.40000000.bcf.csi.OK

indexP: aux/probes.sites.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12272/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12272 -o indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12272/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12004/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12004 -o indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12004/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11994/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11994 -o indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11994/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12749/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12749 -o indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12749/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA10847/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA10847 -o indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA10847/genotype.20.20000001.40000000.log'
	touch indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12716/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12716 -o indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12716/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12829/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12829 -o indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12829/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12275/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12275 -o indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12275/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12750/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12750 -o indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12750/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12348/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12348 -o indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12348/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12347/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12347 -o indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12347/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12003/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12003 -o indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12003/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12286/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12286 -o indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12286/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11829/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11829 -o indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11829/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA07357/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07357 -o indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA07357/genotype.20.20000001.40000000.log'
	touch indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12144/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12144 -o indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12144/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12812/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12812 -o indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12812/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12718/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12718 -o indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12718/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12777/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12777 -o indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12777/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12872/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12872 -o indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12872/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12751/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12751 -o indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12751/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12717/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12717 -o indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12717/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA07051/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07051 -o indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA07051/genotype.20.20000001.40000000.log'
	touch indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11992/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11992 -o indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11992/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12058/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12058 -o indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12058/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12889/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12889 -o indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12889/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12400/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12400 -o indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12400/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12778/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12778 -o indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12778/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12154/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12154 -o indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12154/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11932/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11932 -o indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11932/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA06986/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06986 -o indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA06986/genotype.20.20000001.40000000.log'
	touch indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA07056/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07056 -o indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA07056/genotype.20.20000001.40000000.log'
	touch indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12046/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12046 -o indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12046/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12342/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12342 -o indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12342/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA06984/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06984 -o indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA06984/genotype.20.20000001.40000000.log'
	touch indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12273/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12273 -o indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12273/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12748/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12748 -o indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12748/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12814/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12814 -o indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12814/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12546/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12546 -o indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12546/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12827/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12827 -o indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12827/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12489/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12489 -o indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12489/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12283/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12283 -o indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12283/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11919/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11919 -o indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11919/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11995/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11995 -o indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11995/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA07000/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA07000 -o indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA07000/genotype.20.20000001.40000000.log'
	touch indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA10851/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA10851 -o indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA10851/genotype.20.20000001.40000000.log'
	touch indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12341/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12341 -o indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12341/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11892/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11892 -o indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11892/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12383/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12383 -o indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12383/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA06994/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA06994 -o indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA06994/genotype.20.20000001.40000000.log'
	touch indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12006/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12006 -o indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12006/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11993/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11993 -o indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11993/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12413/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12413 -o indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12413/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11920/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11920 -o indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11920/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK: aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12874/
	scripts/runcluster.pl local 'vt genotype -b test/umake/bams/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12874 -o indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12874/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK

singleBamGenotype: indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK: mergedBams/NA12045.bam.bai.OK aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12045/
	scripts/runcluster.pl local 'vt genotype -b mergedBams/NA12045.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12045 -o indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12045/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK: mergedBams/NA12249.bam.bai.OK aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12249/
	scripts/runcluster.pl local 'vt genotype -b mergedBams/NA12249.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12249 -o indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12249/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK: mergedBams/NA11931.bam.bai.OK aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11931/
	scripts/runcluster.pl local 'vt genotype -b mergedBams/NA11931.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11931 -o indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11931/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK: mergedBams/NA11918.bam.bai.OK aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA11918/
	scripts/runcluster.pl local 'vt genotype -b mergedBams/NA11918.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA11918 -o indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA11918/genotype.20.20000001.40000000.log'
	touch indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK: mergedBams/NA12043.bam.bai.OK aux/probes.sites.20.20000001.40000000.bcf.OK aux/probes.sites.20.20000001.40000000.bcf.csi.OK | indelvcf/NA12043/
	scripts/runcluster.pl local 'vt genotype -b mergedBams/NA12043.bam -r test/chr20Ref/human_g1k_v37_chr20.fa -s NA12043 -o indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf -i 20:20000001-40000000 aux/probes.sites.20.20000001.40000000.bcf 2> indelvcf/NA12043/genotype.20.20000001.40000000.log'
	touch indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK

multiBamGenotype: indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK

indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12272/
	scripts/runcluster.pl local 'vt index indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12004/
	scripts/runcluster.pl local 'vt index indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11994/
	scripts/runcluster.pl local 'vt index indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12749/
	scripts/runcluster.pl local 'vt index indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA10847/
	scripts/runcluster.pl local 'vt index indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12716/
	scripts/runcluster.pl local 'vt index indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12829/
	scripts/runcluster.pl local 'vt index indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12275/
	scripts/runcluster.pl local 'vt index indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12750/
	scripts/runcluster.pl local 'vt index indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12348/
	scripts/runcluster.pl local 'vt index indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12347/
	scripts/runcluster.pl local 'vt index indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12003/
	scripts/runcluster.pl local 'vt index indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12286/
	scripts/runcluster.pl local 'vt index indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11829/
	scripts/runcluster.pl local 'vt index indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA07357/
	scripts/runcluster.pl local 'vt index indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12144/
	scripts/runcluster.pl local 'vt index indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12045/
	scripts/runcluster.pl local 'vt index indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12812/
	scripts/runcluster.pl local 'vt index indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12718/
	scripts/runcluster.pl local 'vt index indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12777/
	scripts/runcluster.pl local 'vt index indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12872/
	scripts/runcluster.pl local 'vt index indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12751/
	scripts/runcluster.pl local 'vt index indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12717/
	scripts/runcluster.pl local 'vt index indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA07051/
	scripts/runcluster.pl local 'vt index indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12249/
	scripts/runcluster.pl local 'vt index indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11992/
	scripts/runcluster.pl local 'vt index indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12058/
	scripts/runcluster.pl local 'vt index indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12889/
	scripts/runcluster.pl local 'vt index indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12400/
	scripts/runcluster.pl local 'vt index indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12778/
	scripts/runcluster.pl local 'vt index indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12154/
	scripts/runcluster.pl local 'vt index indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11932/
	scripts/runcluster.pl local 'vt index indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11931/
	scripts/runcluster.pl local 'vt index indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA06986/
	scripts/runcluster.pl local 'vt index indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA07056/
	scripts/runcluster.pl local 'vt index indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12046/
	scripts/runcluster.pl local 'vt index indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12342/
	scripts/runcluster.pl local 'vt index indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA06984/
	scripts/runcluster.pl local 'vt index indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12273/
	scripts/runcluster.pl local 'vt index indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12748/
	scripts/runcluster.pl local 'vt index indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12814/
	scripts/runcluster.pl local 'vt index indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12546/
	scripts/runcluster.pl local 'vt index indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12827/
	scripts/runcluster.pl local 'vt index indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12489/
	scripts/runcluster.pl local 'vt index indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12283/
	scripts/runcluster.pl local 'vt index indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11919/
	scripts/runcluster.pl local 'vt index indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11995/
	scripts/runcluster.pl local 'vt index indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA07000/
	scripts/runcluster.pl local 'vt index indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA10851/
	scripts/runcluster.pl local 'vt index indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11918/
	scripts/runcluster.pl local 'vt index indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12341/
	scripts/runcluster.pl local 'vt index indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11892/
	scripts/runcluster.pl local 'vt index indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12383/
	scripts/runcluster.pl local 'vt index indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA06994/
	scripts/runcluster.pl local 'vt index indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12006/
	scripts/runcluster.pl local 'vt index indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12043/
	scripts/runcluster.pl local 'vt index indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11993/
	scripts/runcluster.pl local 'vt index indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12413/
	scripts/runcluster.pl local 'vt index indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA11920/
	scripts/runcluster.pl local 'vt index indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK

indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK: indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.OK | indelvcf/NA12874/
	scripts/runcluster.pl local 'vt index indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf 2> indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.log'
	touch indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK

indexG: indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK

final/merge/all.genotypes.20.bcf.OK: indelvcf/NA12272/NA12272.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12004/NA12004.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11994/NA11994.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12749/NA12749.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA10847/NA10847.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12716/NA12716.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12829/NA12829.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12275/NA12275.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12750/NA12750.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12348/NA12348.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12347/NA12347.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12003/NA12003.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12286/NA12286.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11829/NA11829.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07357/NA07357.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12144/NA12144.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12045/NA12045.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12812/NA12812.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12718/NA12718.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12777/NA12777.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12872/NA12872.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12751/NA12751.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12717/NA12717.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07051/NA07051.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12249/NA12249.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11992/NA11992.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12058/NA12058.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12889/NA12889.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12400/NA12400.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12778/NA12778.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12154/NA12154.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11932/NA11932.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11931/NA11931.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06986/NA06986.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07056/NA07056.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12046/NA12046.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12342/NA12342.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06984/NA06984.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12273/NA12273.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12748/NA12748.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12814/NA12814.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12546/NA12546.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12827/NA12827.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12489/NA12489.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12283/NA12283.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11919/NA11919.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11995/NA11995.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA07000/NA07000.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA10851/NA10851.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11918/NA11918.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12341/NA12341.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11892/NA11892.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12383/NA12383.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA06994/NA06994.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12006/NA12006.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12043/NA12043.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11993/NA11993.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12413/NA12413.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA11920/NA11920.genotypes.20.20000001.40000000.bcf.csi.OK indelvcf/NA12874/NA12874.genotypes.20.20000001.40000000.bcf.csi.OK | final/merge/
	scripts/runcluster.pl local 'vt merge -L aux/merge.20.vcf.list.txt -o + | vt compute_features + -o + 2> final/merge/compute_features.20.log | vt remove_overlap + -o final/merge/all.genotypes.20.bcf 2> final/merge/remove_overlap.20.log'
	touch final/merge/all.genotypes.20.bcf.OK

mergeG: final/merge/all.genotypes.20.bcf.OK

final/merge/all.genotypes.20.bcf.csi.OK: final/merge/all.genotypes.20.bcf.OK | final/merge/
	scripts/runcluster.pl local 'vt index final/merge/all.genotypes.20.bcf 2> final/merge/all.genotypes.20.bcf.csi.log'
	touch final/merge/all.genotypes.20.bcf.csi.OK

indexMG: final/merge/all.genotypes.20.bcf.csi.OK

final/all.genotypes.vcf.gz.OK: final/merge/all.genotypes.20.bcf.OK | final/
	scripts/runcluster.pl local 'vt concat final/merge/all.genotypes.20.bcf -o final/all.genotypes.vcf.gz 2> final/concat.log'
	touch final/all.genotypes.vcf.gz.OK

concat: final/all.genotypes.vcf.gz.OK

final/all.genotypes.vcf.gz.tbi.OK: final/all.genotypes.vcf.gz.OK | final/
	scripts/runcluster.pl local 'vt index final/all.genotypes.vcf.gz 2> final/all.genotypes.vcf.gz.tbi.log'
	touch final/all.genotypes.vcf.gz.tbi.OK

indexC: final/all.genotypes.vcf.gz.tbi.OK

aux/:
	mkdir -p aux/

final/:
	mkdir -p final/

final/merge/:
	mkdir -p final/merge/

indelvcf/NA06984/:
	mkdir -p indelvcf/NA06984/

indelvcf/NA06986/:
	mkdir -p indelvcf/NA06986/

indelvcf/NA06994/:
	mkdir -p indelvcf/NA06994/

indelvcf/NA07000/:
	mkdir -p indelvcf/NA07000/

indelvcf/NA07051/:
	mkdir -p indelvcf/NA07051/

indelvcf/NA07056/:
	mkdir -p indelvcf/NA07056/

indelvcf/NA07357/:
	mkdir -p indelvcf/NA07357/

indelvcf/NA10847/:
	mkdir -p indelvcf/NA10847/

indelvcf/NA10851/:
	mkdir -p indelvcf/NA10851/

indelvcf/NA11829/:
	mkdir -p indelvcf/NA11829/

indelvcf/NA11892/:
	mkdir -p indelvcf/NA11892/

indelvcf/NA11918/:
	mkdir -p indelvcf/NA11918/

indelvcf/NA11919/:
	mkdir -p indelvcf/NA11919/

indelvcf/NA11920/:
	mkdir -p indelvcf/NA11920/

indelvcf/NA11931/:
	mkdir -p indelvcf/NA11931/

indelvcf/NA11932/:
	mkdir -p indelvcf/NA11932/

indelvcf/NA11992/:
	mkdir -p indelvcf/NA11992/

indelvcf/NA11993/:
	mkdir -p indelvcf/NA11993/

indelvcf/NA11994/:
	mkdir -p indelvcf/NA11994/

indelvcf/NA11995/:
	mkdir -p indelvcf/NA11995/

indelvcf/NA12003/:
	mkdir -p indelvcf/NA12003/

indelvcf/NA12004/:
	mkdir -p indelvcf/NA12004/

indelvcf/NA12006/:
	mkdir -p indelvcf/NA12006/

indelvcf/NA12043/:
	mkdir -p indelvcf/NA12043/

indelvcf/NA12045/:
	mkdir -p indelvcf/NA12045/

indelvcf/NA12046/:
	mkdir -p indelvcf/NA12046/

indelvcf/NA12058/:
	mkdir -p indelvcf/NA12058/

indelvcf/NA12144/:
	mkdir -p indelvcf/NA12144/

indelvcf/NA12154/:
	mkdir -p indelvcf/NA12154/

indelvcf/NA12249/:
	mkdir -p indelvcf/NA12249/

indelvcf/NA12272/:
	mkdir -p indelvcf/NA12272/

indelvcf/NA12273/:
	mkdir -p indelvcf/NA12273/

indelvcf/NA12275/:
	mkdir -p indelvcf/NA12275/

indelvcf/NA12283/:
	mkdir -p indelvcf/NA12283/

indelvcf/NA12286/:
	mkdir -p indelvcf/NA12286/

indelvcf/NA12341/:
	mkdir -p indelvcf/NA12341/

indelvcf/NA12342/:
	mkdir -p indelvcf/NA12342/

indelvcf/NA12347/:
	mkdir -p indelvcf/NA12347/

indelvcf/NA12348/:
	mkdir -p indelvcf/NA12348/

indelvcf/NA12383/:
	mkdir -p indelvcf/NA12383/

indelvcf/NA12400/:
	mkdir -p indelvcf/NA12400/

indelvcf/NA12413/:
	mkdir -p indelvcf/NA12413/

indelvcf/NA12489/:
	mkdir -p indelvcf/NA12489/

indelvcf/NA12546/:
	mkdir -p indelvcf/NA12546/

indelvcf/NA12716/:
	mkdir -p indelvcf/NA12716/

indelvcf/NA12717/:
	mkdir -p indelvcf/NA12717/

indelvcf/NA12718/:
	mkdir -p indelvcf/NA12718/

indelvcf/NA12748/:
	mkdir -p indelvcf/NA12748/

indelvcf/NA12749/:
	mkdir -p indelvcf/NA12749/

indelvcf/NA12750/:
	mkdir -p indelvcf/NA12750/

indelvcf/NA12751/:
	mkdir -p indelvcf/NA12751/

indelvcf/NA12777/:
	mkdir -p indelvcf/NA12777/

indelvcf/NA12778/:
	mkdir -p indelvcf/NA12778/

indelvcf/NA12812/:
	mkdir -p indelvcf/NA12812/

indelvcf/NA12814/:
	mkdir -p indelvcf/NA12814/

indelvcf/NA12827/:
	mkdir -p indelvcf/NA12827/

indelvcf/NA12829/:
	mkdir -p indelvcf/NA12829/

indelvcf/NA12872/:
	mkdir -p indelvcf/NA12872/

indelvcf/NA12874/:
	mkdir -p indelvcf/NA12874/

indelvcf/NA12889/:
	mkdir -p indelvcf/NA12889/

mergedBams/:
	mkdir -p mergedBams/

