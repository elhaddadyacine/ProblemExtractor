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

let rec get_inferences tstp_lines = 
  match tstp_lines with
  |[] -> []
  |Formula_annot
    (name, 
    ("hypothesis"|"negated_conjecture"), 
    _, 
    Some Inference(_, _, _))::l' 
      -> (List.hd tstp_lines)::(get_inferences l')
  |_::l' -> get_inferences l';;

let problem_to_string line = 
  match line with
  |Include(_, _)   -> "Include"
  |Formula_annot (name, "axiom", body, _)  -> name ^ " Axiom"
  |Formula_annot (name, "hypothesis", body, _)  -> name ^ " Hypothesis"
  |Formula_annot (name, "negated_conjecture", body, _)  -> name ^ " Negated_conjecture"
  |_ -> "Other";;


let get_problems problem_list = List.map (fun p -> problem_to_string p) problem_list;;

let _ =
  match Sys.argv with
  | [|_ ; fname|] ->
      let res : Phrase.tpphrase list = parse_file fname in
      (*Printf.printf "%i items read\n%!" (List.length res);*)
      Printf.printf "%s\n%!" 
      (List.fold_left 
      (fun x y -> x ^ y)
      "" 
      (get_problems res)
      );
  | _             ->
      Printf.eprintf "Usage: %s file.p\n%!" Sys.argv.(0);
      exit 1