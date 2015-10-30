
STAT_GEN_EXES = bamUtil glfExtract glfMerge vcfPileup infoCollector vcfCooker glfMultiples thunderVCF verifyBamID invNorm qplot glfFlex
EXES = samtools samtools-hybrid $(STAT_GEN_EXES) libsvm-3.1 mosaik bwa bgzip tabix premo vt
LIBS = libStatGen libVcf libMach
SUBDIRS = $(EXES) $(LIBS)

CMAKE = cmake

# Build in all subdirectories.
#
# see http://www.gnu.org/software/make/manual/make.html#Phony-Targets
# for a way of improving the following:
#

# Can't build lib in parallel since multiple subdirs write to the library archive
.NOTPARALLEL:

.PHONY: $(SUBDIRS) all test profile opt debug clean install

all: $(SUBDIRS)

test: $(STAT_GEN_EXES) samtools bgzip tabix

profile opt debug: $(STAT_GEN_EXES)

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
	@$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/$@ $@; cd ..

bamUtil: 
	@$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/bam $@; cd ..

samtools:
	$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/$@ $@; cd ..

samtools-hybrid:
	$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/$@ $@; cd ..

bgzip tabix: 
	$(MAKE) -C htslib $(MAKECMDGOALS) $@
	mkdir --p bin/
	cd bin/; ln -fs ../htslib/$@ $@; cd ..

libsvm-3.1:
	$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/svm-predict .; cd ..
	cd bin/; ln -fs ../$@/svm-train .; cd ..

mosaik:
	$(MAKE) -C $@/src $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/MosaikAligner .; cd ..
	cd bin/; ln -fs ../$@/bin/MosaikBuild .; cd ..
	cd bin/; ln -fs ../$@/bin/MosaikJump .; cd ..
	cd bin/; ln -fs ../$@/bin/MosaikText .; cd ..

premo:
	mkdir -p $@/build; cd $@/build; $(CMAKE) ..
	$(MAKE) -C $@/build $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/bin/premo .; cd ..

bwa: 
	$(MAKE) -C bwa $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../bwa/bwa $@; cd ..

vt:
	$(MAKE) -C $@ $(MAKECMDGOALS)
	mkdir --p bin/
	cd bin/; ln -fs ../$@/vt .; cd ..

$(LIBS): 
	@if [ $@ = libStatGen ]; then \
		$(MAKE) -C $@ $(MAKECMDGOALS); \
	else \
		$(MAKE) -C $@; \
	fi
	mkdir --p lib/
	cd lib/; ln -fs ../$@/$@.a $@.a; cd ..
