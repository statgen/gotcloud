OUT_DIR=<outdir_path>
GOTCLOUD_ROOT=<gotcloud_root>

.DELETE_ON_ERROR:

all: all20

all20: subset20 beagle20

subset20: $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist.OK

$(OUT_DIR)/beagle/chr20/subset.OK: beagle20
	ln -f -s $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz
	ln -f -s $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz.tbi
	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz ]; then touch $(OUT_DIR)/beagle/chr20/subset.OK; break; else sleep 10; false; fi; done || exit 17;

$(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist.OK: $(OUT_DIR)/beagle/chr20/subset.OK
	mkdir --p $(OUT_DIR)/thunder/chr20/ALL/split/
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist local 'perl $(GOTCLOUD_ROOT)/scripts/vcfSplit.pl --in $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.ALL.vcf.gz --out $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split --nunit 10000 --noverlap 1000 2> $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.err'
	for i in 1 2 3 4 5 6; do if [ -e $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist ]; then touch $(OUT_DIR)/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist.OK; break; else sleep 10; false; fi; done || exit 17;

beagle20: $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi

$(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz.tbi: $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz.tbi
	bash -c "set -e -o pipefail; perl $(GOTCLOUD_ROOT)/scripts/ligateVcf.pl $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz 2> $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz.err | $(GOTCLOUD_ROOT)/bin/bgzip -c > $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz"
	$(GOTCLOUD_ROOT)/bin/tabix -f -pvcf $(OUT_DIR)/beagle/chr20/chr20.filtered.PASS.beagled.vcf.gz

$(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz.tbi:
	mkdir --p $(OUT_DIR)/beagle/chr20/like
	mkdir --p $(OUT_DIR)/beagle/chr20/split
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/beagle/chr20/like/chr20.PASS.1.gz local 'perl $(GOTCLOUD_ROOT)/scripts/vcf2Beagle.pl --PL --in $(OUT_DIR)/split/chr20/chr20.filtered.PASS.split.1.vcf.gz --out $(OUT_DIR)/beagle/chr20/like/chr20.PASS.1.gz'
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/beagle/chr20/split/bgl.1 local 'java -Xmx4g -jar $(GOTCLOUD_ROOT)/bin/beagle.20101226.jar seed=993478 gprobs=true niterations=50 lowmem=true like=$(OUT_DIR)/beagle/chr20/like/chr20.PASS.1.gz out=$(OUT_DIR)/beagle/chr20/split/bgl.1 >$(OUT_DIR)/beagle/chr20/split/bgl.1.out 2>$(OUT_DIR)/beagle/chr20/split/bgl.1.err'
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf local 'perl $(GOTCLOUD_ROOT)/scripts/beagle2Vcf.pl --filter --beagle $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.gz --invcf $(OUT_DIR)/split/chr20/chr20.filtered.PASS.split.1.vcf.gz --outvcf $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf'
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz local '$(GOTCLOUD_ROOT)/bin/bgzip -f $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf'
	$(GOTCLOUD_ROOT)/scripts/runcluster.pl -bashdir $(OUT_DIR)/jobfiles -log $(OUT_DIR)/umake_test.beagle.Makefile.cluster,$(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz.tbi local '$(GOTCLOUD_ROOT)/bin/tabix -f -pvcf $(OUT_DIR)/beagle/chr20/split/bgl.1.chr20.PASS.1.vcf.gz'


clean:
