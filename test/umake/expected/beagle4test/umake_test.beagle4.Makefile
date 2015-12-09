OUT_DIR=<outdir_path>
GOTCLOUD_ROOT=<gotcloud_root>

.DELETE_ON_ERROR:

all: all20

all20: beagle4_20

beagle4_20: $(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi.OK

$(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi.OK: $(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz.tbi.OK
	perl $(GOTCLOUD_ROOT)/scripts/ligateVcf4.pl --list $(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.list -bgl $(OUT_DIR)/beagle4/chr20/like/chr20.PASS --vcf $(OUT_DIR)/vcfs/chr20/chr20.filtered.vcf.gz --out $(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz
	$(GOTCLOUD_ROOT)/bin/tabix -f -pvcf $(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz
	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi ]; then touch $(OUT_DIR)/beagle4/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi.OK; break; else sleep 10; false; fi; done || exit 17;


$(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz.tbi.OK:
	mkdir --p $(OUT_DIR)/beagle4/chr20/like
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle4.Makefile.cluster,$(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz local 'java -Xmx4g -jar $(GOTCLOUD_ROOT)/bin/b4.r1219.jar seed=993478 gprobs=true gl=$(OUT_DIR)/split4/chr20/chr20.filtered.PASS.split.1.vcf.gz out=$(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1'
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle4.Makefile.cluster,$(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz.tbi local '$(GOTCLOUD_ROOT)/bin/tabix -f -pvcf $(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz'
	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz.tbi ]; then touch $(OUT_DIR)/beagle4/chr20/like/chr20.PASS.1.vcf.gz.tbi.OK; break; else sleep 10; false; fi; done || exit 17;



clean:
