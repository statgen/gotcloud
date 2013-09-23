Contents
--------

[Introduction](#Introduction)

[Where to Find It](#Where_to_Find_It)

-   [Binary Download](#Binary_Download)
-   [Source Code Distribution](#Source_Code_Distribution)

[Usage](#Usage)

-   [Command line](#Command_line)
-   [Input files](#Input_files)
-   [Parameters](#Parameters)
-   [Output files](#Output_files)

[Example](#Example)

-   [Built-in example](#Built-in_example)
-   [Gallery of examples](#Gallery_of_examples)
-   [Diagnose sequencing quality](#Diagnose_sequencing_quality)

[Contact](#Contact)

* * * * *

Introduction
============

The qplot program calculates various summary statistics some of which
are plotted in a PDF file. These statistics can be used to assess the
sequencing quality of sequence reads mapped to the reference genome. The
main statistics are empirical Phred scores which are calculated based on
the background mismatch rate. Background mismatch rate is the rate that
sequenced bases are different from the reference genome, EXCLUDING dbSNP
positions. Other statistics include GC biases, insert size distribution,
depth distribution, genome coverage, empirical Q20 count, and so on.

In the following sections, we will guide you through: [how to obtain
qplot](#Where_to_Find_It), [how to use qplot](#Usage), [example
outputs](#Built-in_example), [interactive diagnostic
plots](#AnchorOfInteractiveQplot), and [real
applications](#Diagnose_sequencing_quality) in which qplot has helped
identify sequencing problems.

Where to Find It
================

You can obtain qplot in two ways:

\(1) Download the pre-compiled binary along with the source code as
described in [Binary Download](#Binary_Download).

\(2) Download source code only and compile it on your own machine.
Please follow the instruction in [Source Code
Distribution](#Source_Code_Distribution) on fetching source code and
building instructions.

Binary Download
---------------

We have prepared a pre-compiled (under Ubuntu) qplot along with source
code . You can download it from: [qplot.20130627.tar.gz (File Size:
1.7G)](http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot.20130627.tar.gz "http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot.20130627.tar.gz")

The executable file is under qplot/bin/qplot.

In addition, we provided the necessary input files under qplot/data/
(NCBI human genome build v37, dbSNP 130, and pre-computed GC file with
windows size 100).

You can also find an example BAM input file under
qplot/example/chrom20.9M.10M.bam. It is taken from the 1000 Genome
Project with sequencing reads aligned to chromosome 20 positions 8M to
9M.

Source Code Distribution
------------------------

We provide a source code only download in
[qplot-source.20130627.tar.gz](http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-source.20130627.tar.gz "http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-source.20130627.tar.gz").
Optionally, you can download example file and/or data file:

[example](http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-example.tar.gz "http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-example.tar.gz"):
example input file, and expected outputs if you following the
[direction](#Built-in_example).

[resources
data](http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-data.tar.gz "http://www.sph.umich.edu/csg/zhanxw/software/qplot/qplot-data.tar.gz"):
necessary input files for qplot, including NCBI human genome build v37,
dbSNP 130, and pre-computed GC file with windows size 100.

You can put above file(s) in the same folder and follow these steps:

-   1. Unarchive downloaded file

<!-- -->

    tar zvxf qplot-source.20130627.tar.gz

A new folder *qplot* will be created.

-   2. Build libStatGen

<!-- -->

    cd qplot
    (cd ../libStatGen; make cloneLib)

This step will download a necessary software library
[libStatGen](http://genome.sph.umich.edu/wiki/C%2B%2B_Library:_libStatGen "http://genome.sph.umich.edu/wiki/C%2B%2B_Library:_libStatGen")
and compile source code into a binary code library.

-   3. Build qplot

<!-- -->

    make

This step will then build qplot. Upon success, the executable qplot can
be found under qplot/bin/.

-   4. (Optional) unarchive example and/or data

<!-- -->

    tar zvxf qplot-example.tar.gz

An example file, *chrom20.9M.10M.bam*, will be extracted to
qplot/example/. It contains \~1.1 million aligned Illumina sequencing
reads of NA12878 from 1000 Genome Project. Example command line,
*cmd.sh*, example outputs, *qplot.pdf*, *qplot.stats*, and *qplot.R* are
also provided and will be extracted qplot/example/ as well.

    tar zvxf qplot-data.tar.gz

Three files will be extracted to qplot/data/: *human.g1k.v37-bs.umfa* is
binary NCBI reference genome build 37; *dbSNP130.UCSC.coordinates.tbl*
is dbSNP version 130; and *human.g1k.w100.gc* is pre-calculated GC
content with windows size 100.

Usage
=====

Command line
------------

After you obtain the qplot executable (either by compiling the source
code or by downloading the pre-compiled binary file), you will find the
executable file under qplot/bin/qplot.

Here is the qplot help page by invoking qplot without any command line
arguments:

     some_linux_host > qplot/bin/qplot
       The following parameters are available.  Ones with "[]" are in effect:
        
        
        
                       References : --reference [/net/fantasia/home/zhanxw/software/qplot/data/human.g1k.v37.fa],
                                    --dbsnp [/net/fantasia/home/zhanxw/software/qplot/data/dbSNP130.UCSC.coordinates.tbl]
          GC content file options : --winsize [100]
                      Region list : --regions [], --invertRegion
                     Flag filters : --read1_skip, --read2_skip, --paired_skip,
                                    --unpaired_skip
                   Dup and QCFail : --dup_keep, --qcfail_keep
                  Mapping filters : --minMapQuality [0.00]
               Records to process : --first_n_record [-1]
                 Lanes to process : --lanes []
            Read group to process : --readGroup []
               Input file options : --noeof
                     Output files : --plot [], --stats [], --Rcode [], --xml []
                      Plot labels : --label [], --bamLabel []
           Obsoleted (DO NOT USE) : --gccontent [], --create_gc

Input files
-----------

qplot runs on the input BAM/SAM file(s) specified on the command-line
after all other parameters.

Additionally, three (3) precomputed files are required.

-   `--reference`

The reference genome is the same as karma reference genome. If the index
files do not exist, qplot will create the index files **automatically**
using the input reference fasta file.

-   `--dbsnp`

This file has two columns. First column is the chromosome name which
must be consistent with the reference created above. Second column is
1-based SNP position. If you want to create your own dbSNP data from
downloaded UCSC dbSNP file, one way to do it is:
`cat dbsnp_129_b36.rod|grep "single" | awk '$4-$3==1' |cut -f2,4 > dbSNP_129_b36.tbl`

-   ` **OBSOLETED** --gccontent, --create_gc `

Although GC content can be calculated on the fly each time, it is much
more efficient to load a precomputed GC content from a file. GC content
file name is automatically determined in this format:
<reference\_genome\_base\_file\_name\>.winsize<gc\_content\_window\_size\>.gc.
For example, if your reference genome is human.g1k.v37.fa and the window
size is 100, then the GC content file name is:
human.g1k.v37.winsize100.gc .

As it said, there is no need to use --gccontent to specify GC content
file in each run.

-   ` input files `

QPLOT take SAM/BAM files.

*Note*: Before running qplot, it is critical to check how the chromosome
names are coded. Some BAM/SAM files use just numbers, others use chr +
numbers. **You need to make sure that the chromosome names from the
reference and dbSNP are consistent with the BAM/SAM files.**

Parameters
----------

Some of the command line parameters are described here, but most are
self explanatory.

-   Flag filter

By default all reads are processed. If it is desired to check only the
first read of a pair, use `--read2_skip` to ignore the second read. And
so on.

-   Duplication and QCFail

By default reads marked as duplication and QCFail are ignored but can be
retained by

    --dup_keep

or

    --qcfail_keep

-   Records to process

The `--first_n_record` option followed by a number, **n**, will enable
qplot to read the first **n** reads to test the bam files and verify it
works.

-   Lanes to process (only works for Illumina sequences)

If the input bam files have more than one lane and only some of them
need to be checked, use something like `--lanes 1,3,5` to specify that
only lanes 1, 3, and 5 need to be checked.

**NOTE** In order for this to work, the lane info has to be encoded in
the read name such that the lane number is the second field with the
delimiter ":".

-   Read group to process :

Read group option can restrict qplot to process a subset of reads. For
example, if BAM contain the following @RG tags:

    @RG ID:UM0348_1:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0348_2:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0348_3:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0348_4:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0360_1:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0360_2:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0360_3:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM
    @RG ID:UM0360_4:1   PL:ILLUMINA LB:M5390    SM:M5390    CN:UM

If specify nothing or not using "--readGroup", QPLOT by default will
process all reads; If specify "--readGroup UM0348", then only read group
UM0348\_1, UM\_0348\_2, UM\_0348\_3, UM\_0348\_4 will be processed; If
specify "--readGroup UM0348\_1", then only one read group UM0348\_1 will
be processed.

-   Input file options :

BAM files are compress by BGZF algorithm and it should contain EOF by
default. QPLOT will by default stop working when it does not found a
valid EOF tag inside BAM files. However, you can force QPLOT to continue
process using --noeof. But you should be award the input files may be
corrupted.

-   Mapping filters

Qplot will exclude reads with lower mapping qualities than the user
specified parameter, `--minMapQuality`. By default, mapped reads with
all mapping quality will be included in the analysis.

-   Region list

If the interest of qplot is a list of regions, e.g. exons, this can be
achieved by providing a list of regions. The regions should be in the
form of "chr start end label" each line in the file (NOTE: *start* and
*end* position are inclusive and they follow the convention of [BED
file](http://genome.ucsc.edu/FAQ/FAQformat#format1 "http://genome.ucsc.edu/FAQ/FAQformat#format1")).
In order for this option to work, within each chromosome (contig) the
regions have to be sorted by starting position, and also the input bam
files have to be sorted. For example, you can create a text file,
region.txt like following:

    1 100 500 region_A
    1 600 800 region_B
    2 100 300 region_C

Then specifying ` --regions region.txt` enables qplot to calculate
various statistics out of sequenced bases only within the above 3
regions.

Qplot also provides the `--invertRegion` option. Enabling this option
tells qplot to operate on those sequence bases that are outside the
given region.

-   Plot labels

Two kinds of labels are enabled. `--label` is the label for the plot
(default is empty) which is appended to the title of each subplot.
`--bamLabels` followed by a column separated list of labels provides the
labels for each input SAM/BAM file, e.g. sample ID (default is numbers
1, 2, ... until the number of input bam files). For example:

    --label Run100 --bamLabels s1,s2,s3,s4,s5,s6,s7,s8

Output files
------------

There are three (optional) output files.

-   `--plot qa.pdf`

Qplot will generate a PDF file named *qa.pdf* containing 2 pages each
with 4 figures. The plot is generated using Rscript.

-   `--stats qa.stats`

Qplot will generate a text file named *qa.stats* containing various
summary statistics for each input BAM/SAM file.

-   `--Rcode qa.R`

Qplot will generate *qa.R* which is the R code used for plotting the
figures in the *qa.pdf* file. If Rscript is not installed in the system,
you can use the qa.R to generate the figures on other machines, or
extract plotting data from each run and combine multiple runs together
to generate more comprehensive plots (See [Example](#Example)).

Example
=======

Qplot can generate diagnostic graphs, related R code, and summary
statistics for each SAM/BAM file.

Built-in example
----------------

In the pre-compiled binary download, you will find a subdirectory named
examples. We provide a sample file from the 1000 Genome project, it
contains aligned reads on chromosome 20 from position 8 Mbp to 9Mbp. You
can invoke qplot using the following command line:

    ../bin/qplot --reference ../data/human.g1k.v37.umfa --dbsnp ../data/dbSNP130.UCSC.coordinates.tbl --gccontent ../data/human.g1k.w100.gc --plot qplot.pdf --stats qplot.stats --Rcode qplot.R --label "chr20:9M-10M" chrom20.9M.10M.bam

Sample outputs are listed below:

\1) Figure:
[qplot.pdf](http://www.mywiki.com/wiki/Media:qplot.pdf "Media:qplot.pdf")

\2) Summary statistics:

    Stats\BAM       chrom20.9M.10M.bam
    TotalReads(e6)  1.11
    MappingRate(%)  97.24
    MapRate_MQpass(%)       97.24
    TargetMapping(%)        0.00
    ZeroMapQual(%)  2.39
    MapQual<10(%)   2.86
    PairedReads(%)  83.76
    ProperPaired(%) 71.34
    MappedBases(e9) 0.04
    Q20Bases(e9)    0.04
    Q20BasesPct(%)  88.63
    MeanDepth       42.22
    GenomeCover(%)  0.03
    EPS_MSE 1.81
    EPS_Cycle_Mean  18.71
    GCBiasMSE       0.01
    ISize_mode      137
    ISize_medium    184
    DupRate(%)      5.90
    QCFailRate(%)   0.00
    BaseComp_A(%)   29.9
    BaseComp_C(%)   20.1
    BaseComp_G(%)   20.2
    BaseComp_T(%)   29.8
    BaseComp_O(%)   0.1

Gallery of examples
-------------------

Here we show qplot can be applied in various sequencing scenarios. Also
users can customize statistics generated by qplot to their needs.

-   Whole genome sequencing with 24-multiplexing

With a customized script, we aggregated 24 bar-coded samples in the same
graph. The graph will help compare sequencing quality between samples.

[QPlot of 24
samples(PDF)](http://www.mywiki.com/wiki/Media:_qplot.Pool.9847.pdf "Media: qplot.Pool.9847.pdf")

-   Interactive qplot

Qplot can be interactive. In the following example, you can use mouse
scroll to zoom in and zoom out on each graph and pan to a certain part
of the graph. By presenting qplot data on a web page, users can easily
identify problematic sequencing samples. Users of qplot can customize
its outputs into web page format greatly easing the data exploring
process.

[QPlot of 24
samples(HTML)](http://www-personal.umich.edu/~zhanxw/qplot.Pool.9847.html "http://www-personal.umich.edu/~zhanxw/qplot.Pool.9847.html")

Diagnose sequencing quality
---------------------------

Qplot is designed and implemented for the need of checking sequencing
quality. Besides the example of analyzing RNA-seq data as shown in our
manuscript, here we demonstrate two additional scenarios in which qplot
can help identify problems after obtaining sequencing data.

-   Base quality distributed abnormally

[Example of qplot helping to identify wrong phred base
quality](http://www.mywiki.com/wiki/Media:_WrongBaseQual.pdf "Media: WrongBaseQual.pdf")

By checking the first graph "Empirical vs reported Phred score", we
found reported base qualities are shifted to the right. In this
particular example, '33' was incorrectly added to all base qualities.
When such data used in variant calling, we may increase false positive
SNP variants.

-   Bar-coded samples

[Example of qplot identifying the effect of ignoring
bar-coding](http://www.mywiki.com/wiki/Media:_WrongBarCoding.pdf "Media: WrongBarCoding.pdf")

By checking "Empirical phred score by cycle" (top right graph on the
first page), we noticed the empirical qualities in the first several
cycles are abnormally low. This phenomenon leads us to hypothesize that
the first several bases have different properties. Further investigation
confirmed that this sequencing was done using bar-coded DNA samples, but
the analysis did not properly de-multiplex each sample.

Contact
=======

Questions and requests should be sent to Bingshan Li
([bingshan@umich.edu](mailto:bingshan@umich.edu "mailto:bingshan@umich.edu"))
or Xiaowei Zhan
([zhanxw@umich.edu](mailto:zhanxw@umich.edu "mailto:zhanxw@umich.edu"))
or Goncalo Abecasis
([goncalo@umich.edu](mailto:goncalo@umich.edu "mailto:goncalo@umich.edu"))
