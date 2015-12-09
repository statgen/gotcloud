OUT_DIR=<outdir_path>
GOTCLOUD_ROOT=<gotcloud_root>

.DELETE_ON_ERROR:

all: all20

all20: thunder20

thunder20: $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.vcf.gz.tbi

$(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.vcf.gz.tbi: $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz.OK
	bash -c "set -e -o pipefail; perl $(GOTCLOUD_ROOT)/scripts/ligateVcf.pl $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz 2> $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.vcf.gz.err | $(GOTCLOUD_ROOT)/bin/bgzip -c > $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.vcf.gz"
	$(GOTCLOUD_ROOT)/bin/tabix -f -pvcf $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.vcf.gz
$(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz.OK:
	mkdir --p $(OUT_DIR)/thunder/chr20/ALL/thunder
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.thunder.Makefile.cluster,$(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz local '$(GOTCLOUD_ROOT)/bin/thunderVCF -r 10 --phase --dosage --inputPhased --states 400 --weightedStates 300 --shotgun $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.1.vcf.gz -o $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1 > $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.out 2> $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.err'
	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz ]; then touch $(OUT_DIR)/thunder/chr20/ALL/thunder/chr20.filtered.PASS.beagled.ALL.thunder.1.vcf.gz.OK; break; else sleep 10; false; fi; done || exit 17;


clean:
