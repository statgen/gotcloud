
GotCloud
========
See <http://genome.sph.umich.edu/wiki/GotCloud> for full GotCloud documentation.

[![Build Status](https://travis-ci.org/statgen/gotcloud.svg?branch=master)](https://travis-ci.org/statgen/gotcloud)

Build GotCloud
--------------
Before running GotCloud, you need to compile the source:

    cd src/; make; cd ..

Test GotCloud
-------------
To test GotCloud, run:

    gotcloud test

Results are self-checked.  If errors occur, the output will say so.  If all tests complete successfully, the output will be deleted.

The output directory will be listed near the top of the output.

To preserve the output files for inspection even when gotcloud runs without errors, run:

    gotcloud test --leave-a-mess


General Help for Variant Calling
--------------------------------

Variant Calling requires three types of input files:

1. a set of BAM files
    - For high quality SNP calls BAM files should already be:
        - duplicate-marked 
        - base-quality recalibrated

2. index file
    - Each line contains at least 3 space-separated columns representing a single individual:

            [SAMPLE_ID] [COMMA SEPARATED POPULATION LABELS] [BAM_FILE1] [BAM_FILE2] ...

    - 1 or more BAMs are allowed per individual

3. configuration file
    - Contains run-time options & command line arguments.  
    - A default configuration is provided.
    - User must specify:
        - `BAM_INDEX =`   # the path/name of the index file
        - `OUT_DIR`

    - Optional specifications...
        - `CHRS =` #space separated list of chromosomes - defaults to 1-22 & X

    - Refer to the default configuration & the wiki page for more information on other settings.
        - <http://genome.sph.umich.edu/wiki/GotCloud:_Variant_Calling_Pipeline#Configuration_File>

Optional input files:

- Pedigree files (PED format) (to specify gender information in chrX calling)
- Target information (UCSC's BED format) in targeted or whole exome capture sequencing

Once these files are configured, to run snp calling and process the data:

    {path}gotcloud snpcall --conf {conf_file} \
    --outdir {output_directory} --numjobs {# of threads to use for processing}

