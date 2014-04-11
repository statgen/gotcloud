for file in umaketest/pvcfs/chr20/*/*log; do \
#echo $file;
echo "Running gpileup version 0.577" > $file;\
echo "bam file                : -.ubam" >> $file;\
echo "input VCF file          : vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf" >> $file;\
echo "output VCF file         : pvcfs/chr20/20000001.25000000/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz (gzip)" >> $file;\
echo "add deletions as bases  : no" >> $file;\
done