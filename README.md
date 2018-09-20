
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
And finally, produice a proof using all sub solutions in `Dedukti`.

You need to have `zenon_modulo` installed to generate the proofs of each sub problem and then generate the `.dko` files with `Dedukti`
#### Exemple


## Contact

Mohamed Yacine EL HADDADD <elhaddad@lsv.fr>
