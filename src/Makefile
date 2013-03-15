include Makefiles/Makefile.include

STAT_GEN_EXES = bamUtil glfExtract glfMerge vcfPileup infoCollector vcfCooker glfMultiples thunderVCF verifyBamID invNorm
EXES = samtools-hybrid $(STAT_GEN_EXES) libsvm-3.1
LIBS = libStatGen libVcf libMach
SUBDIRS = $(EXES) $(LIBS)
#SUBDIRS=glfMerge glfMultiples libStatGen vcfPileup samtools-hybrid infoCollector vcfCooker

# Build in all subdirectories.
#
# see http://www.gnu.org/software/make/manual/make.html#Phony-Targets
# for a way of improving the following:
#

# Can't build lib in parallel since multiple subdirs write to the library archive
.NOTPARALLEL:

.PHONY: $(SUBDIRS) all test clean debug install 

all test opt debug profile: $(SUBDIRS)

install: all

$(INSTALLDIR) :
	@echo " "
	@echo Creating directory $(INSTALLDIR)
	@echo " "
	@mkdir -p $(INSTALLDIR)

help : 
	@echo "Makefile help"
	@echo "-------------"
	@echo "Type...           To..."
	@echo "make              Compile everything "
	@echo "make help         Display this help screen"
	@echo "make all          Compile everything (opt, debug, & profile)"
	@echo "make opt          Compile optimized"
	@echo "make debug        Compile for debug"
	@echo "make profile      Compile for profile"
	@echo "make clean        Delete temporary files"
	@echo "make test         Execute tests (if there are any)"

clean: $(SUBDIRS)
	rm -f $(STAT_GEN_LIB)
	rm -f $(STAT_GEN_LIB_DEBUG)
	rm -f $(STAT_GEN_LIB_PROFILE)
	rm -rf bin
	rm -rf lib

# binaries depends on libStatGen
$(STAT_GEN_EXES): libStatGen

vcfCooker thunderVCF infoCollector: libVcf

thunderVCF: libMach

$(subst bamUtil,,$(STAT_GEN_EXES)): 
	@$(MAKE) OPTFLAG="$(OPTFLAG)" -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/$@ $@; cd ..

bamUtil: 
	@$(MAKE) OPTFLAG="$(OPTFLAG)" -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/bam $@; cd ..

samtools-hybrid: 
	$(MAKE) OPTFLAG="$(OPTFLAG)" -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/$@ $@; cd ..

libsvm-3.1:
	$(MAKE) OPTFLAG="$(OPTFLAG)" -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/svm-predict .; cd ..
	cd bin/; ln -fs ../$@/svm-train .; cd ..


$(LIBS): 
	@$(MAKE) OPTFLAG="$(OPTFLAG)" -C $@ $(MAKECMDGOALS)
	mkdir --p lib/
	cd lib/; ln -fs ../$@/$@.a $@.a; cd ..
