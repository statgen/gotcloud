OUT_DIR=<outdir_path>
GOTCLOUD_ROOT=<gotcloud_root>

.DELETE_ON_ERROR:

all: all20

all20: split4_20

split4_20: $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list.OK

$(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list.OK:
	mkdir --p $(OUT_DIR)/split4/chr20
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.split4.Makefile.cluster,$(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list local 'perl $(GOTCLOUD_ROOT)/scripts/vcfSplit4.pl --vcf $(OUT_DIR)/vcfs/chr20/chr20.filtered.vcf.gz --out $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split --win 10000 --overlap 1000 2> $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.err'

	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list ]; then touch $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list.OK; break; else sleep 10; false; fi; done || exit 17;


clean:
