all: spliter


# Lexer and parser generation.

lextstp.ml: lextstp.mll
	ocamllex lextstp.mll

parsetstp.ml: parsetstp.mly
	ocamlyacc parsetstp.mly

parsetstp.mli: parsetstp.ml

# Compiling.

misc.cmi: misc.mli
	ocamlfind ocamlopt -c $<

misc.cmx: misc.ml misc.cmi
	ocamlfind ocamlopt -c $<

namespace.cmi: namespace.mli
	ocamlfind ocamlopt -c $<

namespace.cmx: namespace.ml namespace.cmi
	ocamlfind ocamlopt -c $<

expr.cmi: expr.mli misc.cmi namespace.cmi
	ocamlfind ocamlopt -c $<

expr.cmx: expr.ml expr.cmi misc.cmx namespace.cmx
	ocamlfind ocamlopt -c $<

phrase.cmi: phrase.mli expr.cmi
	ocamlfind ocamlopt -c $<

phrase.cmx: phrase.ml phrase.cmi expr.cmx
	ocamlfind ocamlopt -c $<

lextstp.cmi: lextstp.mli parsetstp.cmi
	ocamlfind ocamlopt -c $<

lextstp.cmx: lextstp.ml lextstp.cmi parsetstp.cmx 
	ocamlfind ocamlopt -c $<

parsetstp.cmi: parsetstp.mli expr.cmi phrase.cmi
	ocamlfind ocamlopt -c $<

parsetstp.cmx: parsetstp.ml parsetstp.cmi expr.cmx phrase.cmx
	ocamlfind ocamlopt -c $<


spliter: namespace.cmx misc.cmx expr.cmx phrase.cmx parsetstp.cmx lextstp.cmx signature.ml spliter.ml
	ocamlfind ocamlopt -linkpkg -package unix -o $@ $^

# Cleaning.

clean:
	rm -f *.cmi *.cmx *.cmo *.o

distclean: clean 
	rm -f lextstp.ml parsetstp.ml parsetstp.mli spliter
