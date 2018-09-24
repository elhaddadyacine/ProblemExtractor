
# Problem Extractor

A tool to extract `TPTP` problems from a `TSTP` trace and reconstruct the proof in `dedukti`.

## Installation
    
### Dependencies

- `OCaml >= 4.05.1`
- `ocamlbuild`
- `zenon_modulo` (https://github.com/elhaddadyacine/zenon_modulo)
- `dedukti` (optional) (https://github.com/Deducteam/Dedukti)
- `eprover` or any first order automated prover (optional) (https://github.com/eprover/eprover)

### Compilation

First, you need to get the sources :
```bash
    git clone https://github.com/elhaddadyacine/ProblemExtractor.git
```
To compile the tool, just type :

```bash
    make
```
It will generate a native file named `spliter.native` if you want to install the tool in your binary installation folder (where ocaml is installed, if ocaml is installed in the `/usr/bin/` directory then you need to call `make install` with `sudo`) use :

```bash
    make install
```

## Usage

In order to use `Problem Extractor` you need to have a `TSTP` trace (the repository contains an exemple in the root folder named `trace.p`).
You just need to type :
```bash
    ./spliter.native path/to/your/tstp/trace/file
```

Or (if you installed the tool)
```bash
    problem_extractor path/to/your/tstp/trace/file
```

The program will create a folder which has the same name as the trace.
It generates all the sub problems in the `TPTP` format (inside `lemmas` folder) and add a signature file in `dedukti` format.
It generates also a Makefile to produce proofs in `dedukti` and typecheck them.
And finally, produce a proof using all sub solutions in `dedukti`.

You need to have `zenon_modulo` and `dedukti` installed to generate the proofs of each sub problem and then generate the `.dko` files with `dedukti`
#### Exemple

A trace file named `trace.p` in the repository contains an exemple.

The program will generate 3 files, 1 signature file, a Makefile and 1 proof file :
- lemmas/c_0_5.p
- lemmas/c_0_6.p
- lemmas/c_0_7.p
- trace.dk
- Makefile
- proof_trace.dk

We will produce the proof of each sub problem and typecheck them with a simple make (you can specify the folder of `zenon_modulo` logic files with the variable `DIR`, `/usr/local/lib/` by default): 
```bash
cd trace
make DIR=/path/to/zenon/modulo/logic/files
```
Files produced : 
```bash
lemmas/c_0_5.dk         # the proof of each problem (with zenon_modulo)
lemmas/c_0_6.dk         # ...
lemmas/c_0_7.dk         # ...

lemmas/c_0_5.dko        # typeching of each proof (with dedukti)
lemmas/c_0_6.dko        # ...
lemmas/c_0_7.dko        # ...

trace.dko               # the signature of the proof (contains all used symbols)
proof_trace.dko         # the global proof (contains the combination of sub solutions)
```


## Contact

Mohamed Yacine EL HADDADD <elhaddad@lsv.fr>
