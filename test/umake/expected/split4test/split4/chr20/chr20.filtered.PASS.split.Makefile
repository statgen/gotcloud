.DELETE_ON_ERROR:

all: split4/chr20/chr20.filtered.PASS.split.1.vcf.gz

split4/chr20/chr20.filtered.PASS.split.1.vcf.gz: split4/chr20/chr20.filtered.PASS.split.1.vcf
	scripts/../bin/bgzip split4/chr20/chr20.filtered.PASS.split.1.vcf

