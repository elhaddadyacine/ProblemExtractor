
# Problem Extractor

A tool to extract `TPTP` problems from a `TSTP` trace and reconstruct the proof in `Dedukti`.

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
It will generate a native file named `spliter.native` if you want to install the tool in your binary installation folder (where ocaml is installed) use :

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
It generates all the sub problems in the `TPTP` format and add a signature file in `Dedukti` format.
And finally, produce a proof using all sub solutions in `Dedukti`.

You need to have `zenon_modulo` installed to generate the proofs of each sub problem and then generate the `.dko` files with `Dedukti`
#### Exemple

A trace file named `trace.p` in the repository contains an exemple.

The program will generate 3 files 1 signature file and 1 proof file :
- c_0_5.p
- c_0_6.p
- c_0_7.p
- trace.dk
- proof_trace.dk

We will use `zenon_modulo` to produce a proof of each problem
```bash
    zenon_modulo -itptp -odkterm -sig trace trace/c_0_5.p > trace/c_0_5.dk
    zenon_modulo -itptp -odkterm -sig trace trace/c_0_6.p > trace/c_0_6.dk
    zenon_modulo -itptp -odkterm -sig trace trace/c_0_7.p > trace/c_0_7.dk
```

Then, we generate `.dko` of the signature file and for each proof with `Dedukti` in the right order
```bash
    cd trace
    dkcheck -nl -I /path/to/zenon/library trace.dk -e
    dkcheck -nl -I /path/to/zenon/library c_0_5.dk -e
    dkcheck -nl -I /path/to/zenon/library c_0_6.dk -e
    dkcheck -nl -I /path/to/zenon/library c_0_7.dk -e
    dkcheck -nl -I /path/to/zenon/library proof_trace.dk -e
```

## Contact

Mohamed Yacine EL HADDADD <elhaddad@lsv.fr>
