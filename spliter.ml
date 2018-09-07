open Printf;;
open Namespace;;
open Expr;;
open Phrase;;


let report_error lexbuf msg =
  let p = Lexing.lexeme_start_p lexbuf in
  Lextstp.Error.errpos p msg;
  exit 3;
;;

let make_lexbuf stdin_opt f =
  let (name, chan, close) =
    match f with
    | "-" when stdin_opt -> ("", stdin, ignore)
    | _ -> (f, open_in f, close_in)
  in
  let lexbuf = Lexing.from_channel chan in
  lexbuf.Lexing.lex_curr_p <- {
     Lexing.pos_fname = name;
     Lexing.pos_lnum = 1;
     Lexing.pos_bol = 0;
     Lexing.pos_cnum = 0;
  };
  (lexbuf, fun () -> close chan)
;;

let parse_file f =
  try
    let (lexbuf, closer) = make_lexbuf true f in
    try
      let tpphrases = Parsetstp.file Lextstp.token lexbuf in
      closer ();
      tpphrases
    with
    | Parsing.Parse_error -> report_error lexbuf "syntax error."
    | Lextstp.Error.Lex_error msg -> report_error lexbuf msg
  with Sys_error (msg) -> Lextstp.Error.err msg; exit 4
;;

(* let x = Hashtbl.find name_formula_tbl "c_0_0";; *)

(* get only lines that contains inferences *)
let rec get_inferences tstp_lines =
  match tstp_lines with
  |[] -> []
  |Formula_annot
    (_, _, _, Some Inference(_, _, _)) as f::l' -> f::(get_inferences l')
  |_::l' -> get_inferences l';;

(* get the premises of an inference rule *)
let rec get_premises annotation =
  match annotation with
  |Name name -> [name]
  |Inference(_, _, l) -> get_premises_list l
  |List l -> get_premises_list l
  |_ -> []
  and get_premises_list annotation_list =
    match annotation_list with
    |[] -> []
    |a::l' -> (get_premises a) @ (get_premises_list l')
    ;;

(* get the string format of premises *)
let rec print_premises tstp_lines =
  match tstp_lines with
  |[] -> []
  |Formula_annot (name, _, _, Some inf)::l' -> (name, get_premises inf) :: (print_premises l')
  |_::l' -> print_premises l';;


(* let problem_to_string line =
  match line with
  |Include(_, _)   -> "Include"
  |Formula_annot (name, "axiom", body, _)  -> name ^ " Axiom"
  |Formula_annot (name, "hypothesis", body, _)  -> name ^ " Hypothesis"
  |Formula_annot (name, "negated_conjecture", body, _)  -> name ^ " Negated_conjecture"
  |_ -> "Other";; *)



(* let get_problems problem_list = List.map (fun p -> problem_to_string p) problem_list;; *)

(* print used axioms in TPTP format *)
let rec axioms_to_string (name, l) = 
    match l with
    |[]     -> ""
    |x::l'  -> "%---- fof(" ^ x ^ ", axiom, (" ^ (expr_to_string (Hashtbl.find name_formula_tbl x)) ^ ")).\n" ^ (axioms_to_string (name, l'))  
    ;;


let rec hypothesis_to_string (name, l) = 
  match l with
  |[] -> (expr_to_string (Hashtbl.find name_formula_tbl name))
  |x::l' -> "(" ^ (expr_to_string (Hashtbl.find name_formula_tbl x)) ^ ") => (" ^ (hypothesis_to_string (name, l')) ^ ")";;

(* print the goal to prove in TPTP format *)
let goal_to_string (name, l) = 
  "fof(" ^ name ^ ", conjecture, (" ^ (hypothesis_to_string (name, l)) ^ ")).";; 

(* print the whole TPTP plain content *)
let inference_to_string inference = 
  (axioms_to_string inference) ^ (goal_to_string inference);;

(* generate single TPTP file *)
let generate_tptp name lines =
  Printf.printf "Process problem %s%!" name;
  let oc = open_out name in  
    fprintf oc "%s\n" lines;     
    close_out oc;
  Printf.printf "\t \027[32m OK \027[0m\n%!";;           

let rec generate_files tstp_fname premises = 
  match premises with
  |[] -> ()
  |(name, l)::l' -> 
    generate_tptp ( (Sys.getcwd ())^ "/" ^ tstp_fname ^ "/" ^ name ^ ".p") (inference_to_string (name, l));
    generate_files tstp_fname l';;
let insert_symbols ht = 
  Hashtbl.iter (fun x y -> Signature.get_symbols true y) ht;;
let _ =
  match Sys.argv with
  | [|_ ; fname|] ->
      let res : Phrase.tpphrase list = parse_file fname in
      let inferences = get_inferences res in
      let premises = print_premises inferences in
      let name = (Filename.remove_extension (Filename.basename fname)) in 
      if Sys.command ("mkdir -p " ^ (Sys.getcwd ()) ^ "/" ^ name) = 0 
      then () 
      else Printf.printf "Error while creating %s folder " name;
      Printf.printf "Generating %i TPTP Problems from %s trace.\n%!" (List.length premises) fname;
      generate_files name premises;
     (* Printing all formulas in name_formula_tbl *)
     (* Hashtbl.iter (fun x y -> Printf.printf "%s : %s\n%!" x (Expr.expr_to_string y)) Phrase.name_formula_tbl *)
      insert_symbols Phrase.name_formula_tbl;
      Signature.generate_signature_file name Signature.symbols_table;
  | _             ->
      Printf.eprintf "Usage: %s file.p\n%!" Sys.argv.(0);
      exit 1
