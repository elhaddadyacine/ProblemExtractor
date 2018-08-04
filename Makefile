BINDIR=$(dir $(shell which ocaml))
all: spliter.native

spliter.native:
	ocamlbuild $@

# (Un)Installation

install: spliter.native
	@install -m 755 -d $(BINDIR)
	@install -m 755 -p _build/spliter.native $(BINDIR)/problem_extractor
	@echo 'Installation completed'
	@echo 'Type `problem_extractor \path\to\your\trace\file`'
uninstall:
	@rm -f $(BINDIR)/problem_extractor

# Cleaning.

clean:

clean-dk:
	rm -f *.dk

clean-p:
	rm -f *.p

distclean: clean clean-dk
	rm -f lextstp.ml parsetstp.ml parsetstp.mli spliter.native
	ocamlbuild -clean
