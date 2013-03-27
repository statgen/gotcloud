# The command you want to run.
# Example: Use library bam test files, create a results directory, and run
# a test script you have created.
# TEST_COMMAND = ln -sfT $(ACTUAL_PATH)/bam/test/testFiles testFilesLibBam; \
#                mkdir -p results; ./test.sh
TEST_COMMAND=

# Specify any additional operations to do on a clean if applicable.
# It automatically does: rm -f obj/*.o  *~ results/*
# so that does not need to be specified.
TEST_CLEAN = 


########################
# If your tests involves compiling anything
# Specify your Executable name.
EXE = 

# Specify your Files just like with regular source files:
# TOOLBASE - files with both .cpp and .h.  Just include the base name.
# Example if you have Class1.cpp, Class1.h, Class2.cpp, and Class2.cpp, specify:
# TOOLBASE = Class1 Class2
TOOLBASE = 
# SRCONLY - .cpp only files.  Specify the entire name, including the .cpp.
# Example, if you have Main.cpp, and File1.cpp, specify:
# SRCONLY = Main.cpp File1.cpp
SRCONLY = 
# HDRONLY - .h only files.  Specify the entire name, including the .h.
# Example, if you have Template1.h and Template2.h, specify:
# HDRONLY = Template1.h Template2.h
HDRONLY = 

########################
# Optional settings if you need them for your test program.
# Specify any additional compile varaibles you want
# Example:
# DATE=$(shell date)
# USER=$(shell whoami)
# USER_COMPILE_VARS = -DDATE="\"${DATE}\"" -DUSER="\"${USER}\"" -lcrypto
USER_COMPILE_VARS = 

# Specify any additional includes you need.
USER_INCLUDES =

# Specify any additional warnings you need to enable.
# Example: 
# USER_WARNINGS ?= -Werror -Wno-unused-variable $(shell if [ X$(CCVERSION) \> X4.2.0 ] ; then echo " -Wno-unused-result" ; fi)
USER_WARNINGS =

# Specify any TOOLBASE that needs to be re-compiled when any other file
# is modified.  Do NOT specify this same file in TOOLBASE.
# Example: if you have Executable.cpp and Executable.h, specify:
# COMPILE_ANY_CHANGE = BamExecutable
COMPILE_ANY_CHANGE = 

########################
# Include the base Makefile
PARENT_MAKE = Makefile.test
include ../Makefile.inc

########################
# Add any additional targets here.
