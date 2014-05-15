install-perl-deps:
	@$(PWD)/bin/cpanm --without-feature=test --local-lib $(PWD) --self-contained --installdeps $(PWD)

uninstall-perl-deps:
	find lib/perl5/* -maxdepth 1 -name '*GotCloud*' -prune -o -print -exec rm -rf {} \;
	rm -rf bin/config_data bin/json_pp bin/moo-outdated bin/instmodsh bin/package-stash-conflicts bin/prove man/
