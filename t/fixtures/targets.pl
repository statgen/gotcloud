[
          bless( {
                   'step' => 'default',
                   'name' => 'all',
                   'depends' => [
                                  'all20'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'name' => 'all20',
                   'chromosome' => '20',
                   'depends' => [
                                  'split20',
                                  'svm20',
                                  'filt20',
                                  'pvcf20',
                                  'vcf20',
                                  'glf20'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'split20',
                   'depends' => [
                                  'split/chr20/chr20.filtered.PASS.split.vcflist'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'split',
                   'chromosome' => '20',
                   'name' => 'split/chr20/subset.OK',
                   'depends' => [
                                  'vcfs/chr20/chr20.filtered.vcf.gz.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'split',
                   'chromosome' => '20',
                   'name' => 'split/chr20/chr20.filtered.PASS.split.vcflist',
                   'depends' => [
                                  'split/chr20/subset.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'svm20',
                   'depends' => [
                                  'vcfs/chr20/chr20.filtered.vcf.gz.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'svm',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/chr20.filtered.vcf.gz.OK',
                   'depends' => [
                                  'vcfs/chr20/chr20.hardfiltered.vcf.gz.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'pvcf20',
                   'depends' => [
                                  'pvcfs/chr20/20000001.25000000/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'vcfs/chr20/chr20.merged.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'sites',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'step' => 'pvcf',
                   'chromosome' => '20',
                   'name' => 'pvcfs/chr20/20000001.25000000/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'filt20',
                   'depends' => [
                                  'vcfs/chr20/chr20.hardfiltered.vcf.gz.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'filter',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/chr20.hardfiltered.vcf.gz.OK',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.stats.vcf.OK',
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK',
                                  'vcfs/chr20/chr20.merged.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'stats',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.stats.vcf.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'pvcfs/chr20/20000001.25000000/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'pvcfs/chr20/20000001.25000000/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'vcf20',
                   'depends' => [
                                  'vcfs/chr20/chr20.merged.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'vcf',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/chr20.merged.vcf.OK',
                   'depends' => [
                                  'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf_multiple',
                   'chromosome' => '20',
                   'name' => 'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/samples/chr20/20000001.25000000/NA12272.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12004.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11994.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12749.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA10847.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12716.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12829.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12275.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12750.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12348.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12347.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12003.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12286.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11829.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07357.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12144.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12045.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12812.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12718.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12777.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12872.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12751.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12717.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07051.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12249.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11992.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12058.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12889.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12400.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12778.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12154.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11932.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11931.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06986.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07056.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12046.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12342.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06984.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12273.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12748.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12814.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12546.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12827.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12489.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12283.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11919.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11995.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07000.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA10851.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11918.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12341.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11892.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12383.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06994.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12006.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12043.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11993.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12413.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11920.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12874.20.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'default',
                   'chromosome' => '20',
                   'name' => 'glf20',
                   'depends' => [
                                  'glfs/samples/chr20/20000001.25000000/NA12272.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12004.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11994.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12749.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA10847.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12716.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12829.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12275.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12750.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12348.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12347.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12003.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12286.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11829.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07357.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12144.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12045.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12812.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12718.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12777.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12872.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12751.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12717.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07051.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12249.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11992.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12058.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12889.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12400.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12778.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12154.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11932.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11931.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06986.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07056.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12046.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12342.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06984.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12273.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12748.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12814.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12546.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12827.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12489.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12283.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11919.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11995.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA07000.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA10851.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11918.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12341.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11892.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12383.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA06994.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12006.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12043.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11993.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12413.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA11920.20.20000001.25000000.glf.OK',
                                  'glfs/samples/chr20/20000001.25000000/NA12874.20.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12272.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12272',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12004.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12004',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11994.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11994',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12749.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12749',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA10847.20.20000001.25000000.glf.OK',
                   'sample' => 'NA10847',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12716.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12716',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12829.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12829',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12275.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12275',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12750.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12750',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12348.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12348',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12347.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12347',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12003.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12003',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12286.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12286',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11829.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11829',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA07357.20.20000001.25000000.glf.OK',
                   'sample' => 'NA07357',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12144.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12144',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12045.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12045',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/bams/NA12045/chr20/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                                  'glfs/bams/NA12045/chr20/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12812.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12812',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12718.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12718',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12777.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12777',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12872.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12872',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12751.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12751',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12717.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12717',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA07051.20.20000001.25000000.glf.OK',
                   'sample' => 'NA07051',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12249.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12249',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/bams/NA12249/chr20/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                                  'glfs/bams/NA12249/chr20/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11992.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11992',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12058.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12058',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12889.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12889',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12400.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12400',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12778.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12778',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12154.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12154',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11932.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11932',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11931.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11931',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/bams/NA11931/chr20/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                                  'glfs/bams/NA11931/chr20/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA06986.20.20000001.25000000.glf.OK',
                   'sample' => 'NA06986',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA07056.20.20000001.25000000.glf.OK',
                   'sample' => 'NA07056',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12046.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12046',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12342.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12342',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA06984.20.20000001.25000000.glf.OK',
                   'sample' => 'NA06984',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12273.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12273',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12748.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12748',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12814.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12814',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12546.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12546',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12827.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12827',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12489.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12489',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12283.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12283',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11919.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11919',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11995.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11995',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA07000.20.20000001.25000000.glf.OK',
                   'sample' => 'NA07000',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA10851.20.20000001.25000000.glf.OK',
                   'sample' => 'NA10851',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11918.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11918',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/bams/NA11918/chr20/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                                  'glfs/bams/NA11918/chr20/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12341.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12341',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11892.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11892',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12383.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12383',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA06994.20.20000001.25000000.glf.OK',
                   'sample' => 'NA06994',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12006.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12006',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12043.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12043',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => [
                                  'glfs/bams/NA12043/chr20/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                                  'glfs/bams/NA12043/chr20/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK'
                                ]
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11993.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11993',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12413.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12413',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA11920.20.20000001.25000000.glf.OK',
                   'sample' => 'NA11920',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'step' => 'glf',
                   'chromosome' => '20',
                   'name' => 'glfs/samples/chr20/20000001.25000000/NA12874.20.20000001.25000000.glf.OK',
                   'sample' => 'NA12874',
                   'region_end' => '25000000',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12045/chr20/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12045',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12045/chr20/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12045',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12249/chr20/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12249',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12249/chr20/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12249',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA11931/chr20/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA11931',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA11931/chr20/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA11931',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA11918/chr20/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA11918',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA11918/chr20/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA11918',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12043/chr20/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12043',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' ),
          bless( {
                   'bam' => 'NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
                   'name' => 'glfs/bams/NA12043/chr20/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK',
                   'step' => 'glf',
                   'chromosome' => '20',
                   'region_end' => '25000000',
                   'sample' => 'NA12043',
                   'region_start' => '20000001',
                   'depends' => []
                 }, 'GotCloud::Umake::Makefile::Target' )
        ];
