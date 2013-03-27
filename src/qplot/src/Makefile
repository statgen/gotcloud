# Name of the executable
EXE=qplot
########################
# The Files:
TOOLBASE = GCContent  QSamFlag Sequence BamQC QCStats MmapFile DepthCounter
SRCONLY=main.cpp
HDRONLY=FlagDef.h

########################
# Include the base Makefile
PARENT_MAKE = Makefile.src
include ../Makefile.inc

########################
# Add any additional targets here.
.PHONY: mytest testRef
mytest: 
	echo "test BEGIN"
	(cd ../test && ../bin/qplot --dbsnp /net/wonderland/home/bingshan/data/db/dbSNP/dbSNP130.UCSC.coordinates.tbl --first_n_record 20000 --stats qplot.stat --plot qplot.pdf --Rcode qplot.R --label 111409177.recal,111409333.recal --bamLabel 111409177.recal.bam,111409333.recal.bam 111409177.recal.bam 111409333.recal.bam)
	(diff ../test/qplot.stat ../test/qplot.stat.correct && echo "stat does not match")
	# (diff ../test/qplot.pdf ../test/qplot.pdf.correct && echo "pdf does not match")
	(diff ../test/qplot.R ../test/qplot.R.correct && echo "Rcode does not match")
	echo "test DONE"
testRef:
	echo "generate correct test reference"
	(cd ../test && /net/fantasia/home/bingshan/code/pipeline/qplot/qplot/qplot --dbsnp /net/wonderland/home/bingshan/data/db/dbSNP/dbSNP130.UCSC.coordinates.tbl --first_n_record 20000 --stats qplot.stat.correct --plot qplot.pdf.correct --Rcode qplot.R.correct --label 111409177.recal,111409333.recal --bamLabel 111409177.recal.bam,111409333.recal.bam 111409177.recal.bam 111409333.recal.bam)
	echo "DONE"
