.PHONY : clean


ifeq ($(UMAKE_TEST_DIR),)
$(error UMAKE_TEST_DIR is not defined)
endif
TEST_DIR=$(UMAKE_TEST_DIR)/umaketest
BASE_DIR=../..
EXPECTED_DIR:=expected/umaketest

VCF_GZS_WITH_DIR:=$(wildcard $(EXPECTED_DIR)/pvcfs/chr20/*/*.vcf.gz) $(wildcard $(EXPECTED_DIR)/vcfs/chr20/*.vcf.gz) $(wildcard $(EXPECTED_DIR)/split/chr20/*.vcf.gz)
VCF_GZS_WITH_SUBDIR:=$(subst $(EXPECTED_DIR)/,,$(VCF_GZS_WITH_DIR))
VCF_GZS:=$(notdir $(VCF_GZS_WITH_DIR))
SKIP_GZS=$(addprefix -x ,$(VCF_GZS))
TBI1=chr20.filtered.vcf.gz.tbi

test: clean
	@mkdir -p $(TEST_DIR)
	@$(BASE_DIR)/bin/umake.pl --conf umake_test.conf --snpcall --outdir $(TEST_DIR) --numjobs 2
	diff -r $(SKIP_GZS) -x $(TBI1) -I "bin/samtools-hybrid view -q 20 -F 0x0704 -uh" -I "^Analysis completed on " -I "^Analysis finished on " -I "^Analysis started on " -I "^##filedate=" -I '^Writing to VCF file .*vcfs/chr20/chr20\.filtered\.sites\.vcf$\' -I '^INDEL5 : INDEL >= 5 bp with .*ref/indels/1kg\.pilot_release\.merged\.indels\.sites\.hg19\.chr20\.vcf$\' -I '^\s*Pedigree File : --ped \[.*glfs/samples/chr20/20000001.25000000/glfIndex\.ped\]$\' -I '^\s*Input Options : --anchor \[.*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.vcf\],$\' -I '^\s*--prefix \[.*pvcfs/chr20/20000001.25000000/\],$\' -I '^\s*--index \[.*umake_test\.index\]$\' -I '^\s*Output Options : --outvcf \[.*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.stats\.vcf\],$\' -I '^\s*Base Call File : .*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.vcf (-bname)$\' -I '^.*glfs/samples/chr20/20000001.25000000/NA[0-9]*\.20\.20000001.25000000\.glf$\' -I '^.*pvcfs/chr20/20000001.25000000/NA[0-9]*\.mapped.*\.bam\.20\.20000001.25000000\.vcf\.gz$\' -I '^Opening /.*split/chr20/chr20\.filtered\.PASS\.split\.[1-6]\.vcf\.\.\.$\' -I '^.*split/chr20/chr20\.filtered\.PASS\.split\.[1-6]\.vcf\.gz$\' -I '^bam file\s* : .*bams/NA[0-9]*\.mapped.*\.bam$\' -I '^input VCF file\s*: .*vcfs/chr20/20000001.25000000/chr20\.20000001.25000000\.sites\.vcf$\' -I '^bam index file\s*: .*bams/NA[0-9]*\.mapped.*\.bam\.bai$\' -I '^output VCF file\s*: .*pvcfs/chr20/20000001.25000000/NA[0-9]*\.mapped.*\.bam\.20\.20000001.25000000\.vcf\.gz (gzip)$\' -I '^NA[0-9]*\s*NA[0-9]*\s*0\s*0\s*2\s*.*glfs/samples/chr20/20000001.25000000/NA[0-9]*\.20\.20000001.25000000\.glf$\' $(TEST_DIR)/ $(EXPECTED_DIR)/ -I '^OUTPUT_DIR=.*umaketest$\' -I '^UMAKE_ROOT=.*$\'
	@status=0; for file in $(VCF_GZS_WITH_SUBDIR); do \
	   zdiff -I"^##filedate=.*$$" -I"^#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	.*$${file}$$" $(EXPECTED_DIR)/$$file $(TEST_DIR)/$$file; \
	   if [ $$? -ne 0 ] ; then status=1; echo $$file failed; fi; \
	done; if [ $$status -ne 0 ]; then exit 1; fi;
	@if [ ! -e $(TEST_DIR)/vcfs/chr20/$(TBI1) ]; then \
		echo "ERROR, Missing: $(TEST_DIR)/vcfs/chr20/$(TBI1)"; [ -e $(TEST_DIR)/vcfs/chr20/$(TBI1) ]; fi
clean:
	rm -rf $(TEST_DIR)
