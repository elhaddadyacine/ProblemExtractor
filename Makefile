all: spliter.native

spliter.native:
	ocamlbuild $@

# Cleaning.

clean:

clean-dk:
	rm -f *.dk

clean-p:
	rm -f *.p

distclean: clean clean-dk
	rm -f lextstp.ml parsetstp.ml parsetstp.mli spliter.native
	ocamlbuild -clean
