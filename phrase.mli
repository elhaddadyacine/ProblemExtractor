open Expr;;
open Hashtbl;;

type inductive_arg =
  | Param of string
  | Self
;;

type phrase =
  | Hyp of string * expr * int
  | Def of definition
  | Sig of string * string list * string  (* sym, args, result *)
  | Inductive of
     string * string list * (string * inductive_arg list) list * string
  | Rew of string * expr * int
;;

type zphrase =
  | Zhyp of string * expr * int
  | Zdef of definition
  | Zsig of string * string list * string
  | Zinductive of
     string * string list * (string * inductive_arg list) list * string
  | Zinclude of string;;

val name_formula_tbl : (string,expr) Hashtbl.t;;

val separate :
  string list -> phrase list -> definition list * (expr * int) list;;


type infoitem =
  | Cte of string
  | Fun of string * (infoitem list)

type tpannot =
  | File of string
  | Inference of string * (infoitem list) * (tpannot list)
  | Name of string
  | List of (tpannot list)
  | Other of string
;;

type tpphrase =
  | Include of string * string list option
  | Formula of string * string * expr * (string option)
  | Formula_annot of string * string * expr * (tpannot option)
  | Annotation of string
;;
val change_to_def : string list -> expr -> definition;;
