EXE=libMach.a
TOOLBASE = CostCalculator DosageCalculator ErrorRate HaplotypeKey HaplotypeLoader Haplotyper Manners MathStats OutputHandlers MergeHaplotypes
SRCONLY = AssociationAnalysis.cpp
USER_INCLUDES = -I../include/

VERSION=1.0.0
DATE=$(shell date)
USER=$(shell whoami)
USER_COMPILE_VARS = -DDATE="\"${DATE}\"" -DVERSION="\"${VERSION}\"" -DUSER="\"${USER}\"" -lcrypto

COMPILE_ANY_CHANGE = $(LIB)

LIB_PATH_GENERAL ?=../libStatGen
LIB_PATH_BAM_UTIL ?= $(LIB_PATH_GENERAL)
include $(LIB_PATH_BAM_UTIL)/Makefiles/Makefile.libsrc

$(LIB_PATH_BAM_UTIL)/Makefiles/Makefile.src:
	@echo Unable to locate: $(LIB_PATH_BAM_UTIL)/Makefiles/Makefile.src
	@echo To change the location, set LIB_PATH_GENERAL or LIB_PATH_BAM_UTIL to the appropriate path to libStatGen.  Or specify \"make LIB_PATH_GENERAL=yourPath\" or \"make LIB_PATH_BAM_UTIL=yourPath\"
	@echo Use make download if you have git and want to download the current libStatGen to that location

download:
	git clone git://github.com/statgen/libStatGen.git $(LIB_PATH_BAM_UTIL)
#	if test -d $(LIB_PATH_BAM_UTIL); then echo found; else echo not found; fi
