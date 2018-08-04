open Expr;;
let symbols_table = Hashtbl.create 100;;

let rec get_symbols e  =  
  match e with
  |Eapp (Evar(x, _), l, _)  -> Hashtbl.replace symbols_table x (List.length l); List.iter get_symbols l
  |Eor (e1, e2, _)          -> get_symbols e1; get_symbols e2 
  |Eall (_, e', _)          -> get_symbols e'
  |Eex (_, e', _)           -> get_symbols e'  
  |Enot (e', _)             -> get_symbols e'
  |Eimply(a, b, _)          -> get_symbols a; get_symbols b
  |Eequiv(a, b, _)          -> get_symbols a; get_symbols b
  |_ -> ()
  ;;

let rec generate_iota p =
    match p with
    |0          -> ""
    |x          -> "zen.term (zen.iota) -> " ^ (generate_iota (x - 1));;

let get_type n =
    match n with
    |0          -> "zen.term (zen.iota)"
    |n          -> (generate_iota n) ^ " zen.prop";;

let print_symbols ht = 
    Hashtbl.iter (fun x n -> Printf.printf "def %s : %s.\n%!" x (get_type n)) ht;; 

(* Generating signature file *)
let generate_signature_file name ht =
    let name_dk = name ^ ".dk" in  
  Printf.printf "Generating signature file %s%!" name_dk;
  let oc = open_out ((Sys.getcwd ()) ^ "/" ^ name ^ "/" ^ name_dk) in
    Hashtbl.iter (fun x n -> Printf.fprintf oc "def %s : %s.\n" x (get_type n)) ht;
    close_out oc;
  Printf.printf "\t \027[32m OK \027[0m\n%!";;