.PHONY : all Sample1 Sample2 Sample3

all: Sample1 Sample2 Sample3

Sample1:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) <gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/Makefiles/jobfiles local 'make -f <outdir_path>/Makefiles/align_Sample1.Makefile  > <outdir_path>/Makefiles/align_Sample1.Makefile.log'

Sample2:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) <gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/Makefiles/jobfiles local 'make -f <outdir_path>/Makefiles/align_Sample2.Makefile  > <outdir_path>/Makefiles/align_Sample2.Makefile.log'

Sample3:
	MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS))) <gotcloud_root>/scripts/runcluster.pl -bashdir <outdir_path>/Makefiles/jobfiles local 'make -f <outdir_path>/Makefiles/align_Sample3.Makefile  > <outdir_path>/Makefiles/align_Sample3.Makefile.log'

