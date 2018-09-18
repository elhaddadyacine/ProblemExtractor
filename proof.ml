open Expr;;
let print_var v signame = if signame = "" then v else signame ^ "." ^ v;;
let rec print_dk_type ex signame = 
    match ex with
     Efalse             -> "zen.False"
    |Etrue              -> "zen.True"
    |Evar (x, _)        -> x
    |Eapp (Evar (e, _), [], _)    -> print_var e signame
    |Eapp (Evar (e, _), l, _)     -> (print_var e signame) ^ " " ^ (print_dk_type_vars l signame)
    |Eor (e1, e2, _)    ->  "zen.or \n(" ^ (print_dk_type e1 signame) ^ ")\n(" ^ (print_dk_type e2 signame) ^ ")"
    |Eall (v, e, _)     -> "zen.forall (" ^ (print_dk_type v "") ^ ")\n(" ^ (print_dk_type e signame) ^ ")" 
    |Eex (v, e, _)      -> "zen.exists (" ^ (print_dk_type v "") ^ ")\n(" ^ (print_dk_type e signame) ^ ")" 
    |Enot (e, _) -> "zen.not (" ^ (print_dk_type e signame) ^ ")"
    |Eimply(a, b, _) -> "zen.imp \n(" ^ (print_dk_type a signame) ^ ")\n(" ^ (print_dk_type b signame) ^ ")"
    |Eequiv(a, b, _) -> "zen.eqv \n(" ^ (print_dk_type a signame) ^ ")\n(" ^ (print_dk_type b signame) ^ ")"
    |_ -> failwith "Formula not accepted"

    and print_dk_type_vars l signame = 
        match l with
         []             -> ""
        |x::l'          -> (print_dk_type x signame) ^ " " ^ (print_dk_type_vars l' signame)
;;

let rec generate_dk name l signame = 
    let name_file = ( (Sys.getcwd ())^ "/" ^ name ^ "/proof_" ^ name ^ ".dk") in 
    let oc = open_out name_file in
        Printf.printf "Generating the proof file %s%!" name_file;
        Printf.fprintf oc "def proof_%s : \n(" name;
        generate_dk_list oc l signame;
        Printf.fprintf oc ")\n\n:= ";
        close_out oc;
        Printf.printf "\t \027[32m OK \027[0m\n%!"
and

generate_dk_list oc l signame =
    match l with
     []                 -> ()
    |x::[]              -> Printf.fprintf oc "zen.proof (%s) \n\n->\n\nzen.seq" (print_dk_type (Hashtbl.find Phrase.name_formula_tbl x) signame)
    |x::l'              -> Printf.fprintf oc "zen.proof (%s) \n\n->\n\n" (print_dk_type (Hashtbl.find Phrase.name_formula_tbl x) signame); generate_dk_list oc l' signame
;; 