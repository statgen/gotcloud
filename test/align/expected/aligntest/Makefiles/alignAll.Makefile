.PHONY : all Sample1 Sample2 Sample3

all: Sample1 Sample2 Sample3

Sample1:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) scripts/runcluster.pl -bashdir Makefiles/jobfiles local 'make -f Makefiles/align_Sample1.Makefile  > Makefiles/align_Sample1.Makefile.log'

Sample2:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) scripts/runcluster.pl -bashdir Makefiles/jobfiles local 'make -f Makefiles/align_Sample2.Makefile  > Makefiles/align_Sample2.Makefile.log'

Sample3:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) scripts/runcluster.pl -bashdir Makefiles/jobfiles local 'make -f Makefiles/align_Sample3.Makefile  > Makefiles/align_Sample3.Makefile.log'

