.DELETE_ON_ERROR:

all: <outdir_path>/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz

<outdir_path>/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz: <outdir_path>/split4/chr20/chr20.filtered.PASS.split.1.vcf
	<gotcloud_root>/scripts/../bin/bgzip <outdir_path>/split4/chr20/chr20.filtered.PASS.split.1.vcf

