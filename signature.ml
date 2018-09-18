open Expr;;
let symbols_table = Hashtbl.create 100;;

let rec get_symbols b e =  
  match e with
  |Eapp (Evar(x, _), l, _)  -> Hashtbl.replace symbols_table x (List.length l, b); List.iter (get_symbols false) l
  |Eor (e1, e2, _)          -> get_symbols true e1; get_symbols true e2
  |Eall (_, e', _)          -> get_symbols true e' 
  |Eex (_, e', _)           -> get_symbols true e'  
  |Enot (e', _)             -> get_symbols true e'
  |Eimply(a, b, _)          -> get_symbols true a; get_symbols true b
  |Eequiv(a, b, _)          -> get_symbols true a; get_symbols true b
  |_ -> ()
  ;;

let rec generate_iota p =
    match p with
    |0          -> ""
    |x          -> "zen.term (zen.iota) -> " ^ (generate_iota (x - 1));;

let get_type b n =
    match (b, n) with
     (0, true)           -> "zen.prop"
    |(0, false)           -> "zen.term (zen.iota)"
    |(n, false)          -> (generate_iota n) ^ " zen.term (zen.iota)"
    |(n, true)           -> (generate_iota n) ^ " zen.prop";;

let print_symbols ht = 
    Hashtbl.iter (fun x n -> Printf.printf "def %s : %s.\n%!" x (get_type (fst n) (snd n))) ht;; 

(* Generating signature file *)
let generate_signature_file name ht =
    let name_dk = name ^ ".dk" in  
    let name = ((Sys.getcwd ()) ^ "/" ^ name ^ "/" ^ name_dk) in 
    let oc = open_out name in
        Printf.printf "Generating signature file %s%!" name;
        Hashtbl.iter (fun x n -> Printf.fprintf oc "def %s : %s.\n" x (get_type (fst n) (snd n))) ht;
        close_out oc;
        Printf.printf "\t \027[32m OK \027[0m\n%!";;