




(****************Testing auxiliary functions******************)

(*Getting set of all non-terminals IN ORDER*)
type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet;;

let get_list_non_terminal_test =  (get_list_non_terminal [] 
[(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])])
= [Snore; Quiet;Shout;Grunt]
    ;;

let get_list_non_terminal_test2 =  (get_list_non_terminal [] []= [])
    ;;

let non_terminals_set_test = (non_terminals_set  [(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])])
= [Snore; Quiet;Shout;Grunt]
;;
   
(*Getting the right hand side of the rules IN ORDER for a single left hand side*)
let find_list_right_hand_sides_test = (find_list_right_hand_sides 
[(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])] Shout)
= [[T "otherstuff!"];[T "aooogah!"]] 
;;

let find_list_right_hand_sides_test = (find_list_right_hand_sides 
[(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])] Grunt)
= [[T "khrgh"]; [T "huhuhu"]] 
;;

(*aggregate_right_side tests*)
let aggregate_right_side_test = (aggregate_right_side 
[(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])] Grunt)
= (Grunt, [[T "khrgh"]; [T "huhuhu"]]) 
;;

(*Getting the right hand side of the rules IN ORDER for all left hand sides*)
let aggregate_right_side_all_test = (
    aggregate_right_side_all [(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])] 
    [Snore;Quiet;Shout;Grunt]
 = [(Snore,[[T "ZZZ"]]); (Quiet,[[]]);(Shout,[[T "otherstuff!"];[T "aooogah!"]]); (Grunt,[[T "khrgh"]; [T "huhuhu"]])]
 )
 ;;
 
let ag_rs_rules_all_test = (
    ag_rs_rules_all [(Snore, [T "ZZZ"]); (Quiet, []);(Shout, [T "otherstuff!"]); (Grunt, [T "khrgh"]); (Grunt, [T "huhuhu"]); (Shout, [T "aooogah!"])] 
 = [(Snore,[[T "ZZZ"]]); (Quiet,[[]]);(Shout,[[T "otherstuff!"];[T "aooogah!"]]); (Grunt,[[T "khrgh"]; [T "huhuhu"]])]
 )
 ;;
 
 (*Test to find key in the the list of tupples*)
 let search_key_test1 = search_key [(Snore,[[T "ZZZ"]]); (Quiet,[[]]);(Shout,[[T "otherstuff!"];[T "aooogah!"]]); (Grunt,[[T "khrgh"]; [T "huhuhu"]])] Quiet
 = [[]]
 ;;
 
  let search_key_test2 = search_key [(Snore,[[T "ZZZ"]]); (Quiet,[[]]);(Shout,[[T "otherstuff!"];[T "aooogah!"]]); (Grunt,[[T "khrgh"]; [T "huhuhu"]])] Shout
 = [[T "otherstuff!"];[T "aooogah!"]]
 ;;
 
   let search_key_test3 = search_key [(Snore,[[T "ZZZ"]]); (Quiet,[[]]);(Shout,[[T "otherstuff!"];[T "aooogah!"]]); (Grunt,[[T "khrgh"]; [T "huhuhu"]])] Conversation
 = []
 ;;
 
 (******************Test grammar conversion**********************)
 type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet;;
 
 let giant_grammar =
  Conversation,
  [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]
  ;;
  
let giant_to_func_grammar = convert_grammar giant_grammar
  ;;
 
let convert_grammar_test0 fst giant_to_func_grammar = Conversation;;
let convert_grammar_test =  (snd giant_to_func_grammar) Quiet = [[]] ;;
let convert_grammar_test2 = (snd giant_to_func_grammar) Sentence = [[N Quiet];[N Grunt];[N Shout]] ;;
let convert_grammar_test3 = (snd giant_to_func_grammar) Conversation = [[N Snore];[N Sentence; T","; N Conversation]] ;;



(*********************Testing parse_prefix function****************************)
let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None
   

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num   
 
let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
	 [[N Num];
	  [N Lvalue];
	  [N Incrop; N Lvalue];
	  [N Lvalue; N Incrop];
	  [T"("; N Expr; T")"]]
     | Lvalue ->
	 [[T"$"; N Expr]]
     | Incrop ->
	 [[T"++"];
	  [T"--"]]
     | Binop ->
	 [[T"+"];
	  [T"-"]]
     | Num ->
	 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
	  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])
	  
let test0 =
  ((parse_prefix awkish_grammar accept_all ["ouch"]) = None)
  ;;
  
let test1 =
  ((parse_prefix awkish_grammar accept_all ["9"])
   = Some ([(Expr, [N Term]); (Term, [N Num]); (Num, [T "9"])], []))

let test2 =
  ((parse_prefix awkish_grammar accept_all ["9"; "+"; "$"; "1"; "+"])
   = Some
       ([(Expr, [N Term; N Binop; N Expr]); (Term, [N Num]); (Num, [T "9"]);
	 (Binop, [T "+"]); (Expr, [N Term]); (Term, [N Lvalue]);
	 (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Num]);
	 (Num, [T "1"])],
	["+"]))

let test3 =
  ((parse_prefix awkish_grammar accept_empty_suffix ["9"; "+"; "$"; "1"; "+"])
   = None)

(* This one might take a bit longer.... *)
let test4 =
 ((parse_prefix awkish_grammar accept_all
     ["("; "$"; "8"; ")"; "-"; "$"; "++"; "$"; "--"; "$"; "9"; "+";
      "("; "$"; "++"; "$"; "2"; "+"; "("; "8"; ")"; "-"; "9"; ")";
      "-"; "("; "$"; "$"; "$"; "$"; "$"; "++"; "$"; "$"; "5"; "++";
      "++"; "--"; ")"; "-"; "++"; "$"; "$"; "("; "$"; "8"; "++"; ")";
      "++"; "+"; "0"])
  = Some
     ([(Expr, [N Term; N Binop; N Expr]); (Term, [T "("; N Expr; T ")"]);
       (Expr, [N Term]); (Term, [N Lvalue]); (Lvalue, [T "$"; N Expr]);
       (Expr, [N Term]); (Term, [N Num]); (Num, [T "8"]); (Binop, [T "-"]);
       (Expr, [N Term; N Binop; N Expr]); (Term, [N Lvalue]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term; N Binop; N Expr]);
       (Term, [N Incrop; N Lvalue]); (Incrop, [T "++"]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term; N Binop; N Expr]);
       (Term, [N Incrop; N Lvalue]); (Incrop, [T "--"]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term; N Binop; N Expr]);
       (Term, [N Num]); (Num, [T "9"]); (Binop, [T "+"]); (Expr, [N Term]);
       (Term, [T "("; N Expr; T ")"]); (Expr, [N Term; N Binop; N Expr]);
       (Term, [N Lvalue]); (Lvalue, [T "$"; N Expr]);
       (Expr, [N Term; N Binop; N Expr]); (Term, [N Incrop; N Lvalue]);
       (Incrop, [T "++"]); (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
       (Term, [N Num]); (Num, [T "2"]); (Binop, [T "+"]); (Expr, [N Term]);
       (Term, [T "("; N Expr; T ")"]); (Expr, [N Term]); (Term, [N Num]);
       (Num, [T "8"]); (Binop, [T "-"]); (Expr, [N Term]); (Term, [N Num]);
       (Num, [T "9"]); (Binop, [T "-"]); (Expr, [N Term]);
       (Term, [T "("; N Expr; T ")"]); (Expr, [N Term]); (Term, [N Lvalue]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Lvalue]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Lvalue]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Lvalue; N Incrop]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Lvalue; N Incrop]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Incrop; N Lvalue]);
       (Incrop, [T "++"]); (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
       (Term, [N Lvalue; N Incrop]); (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
       (Term, [N Num]); (Num, [T "5"]); (Incrop, [T "++"]); (Incrop, [T "++"]);
       (Incrop, [T "--"]); (Binop, [T "-"]); (Expr, [N Term]);
       (Term, [N Incrop; N Lvalue]); (Incrop, [T "++"]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Lvalue; N Incrop]);
       (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
       (Term, [T "("; N Expr; T ")"]); (Expr, [N Term]);
       (Term, [N Lvalue; N Incrop]); (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
       (Term, [N Num]); (Num, [T "8"]); (Incrop, [T "++"]); (Incrop, [T "++"]);
       (Binop, [T "+"]); (Expr, [N Term]); (Term, [N Num]); (Num, [T "0"])],
      []))

let rec contains_lvalue = function
  | [] -> false
  | (Lvalue,_)::_ -> true
  | _::rules -> contains_lvalue rules

let accept_only_non_lvalues rules frag =
  if contains_lvalue rules
  then None
  else Some (rules, frag)

let test5 =
  ((parse_prefix awkish_grammar accept_only_non_lvalues
      ["3"; "-"; "4"; "+"; "$"; "5"; "-"; "6"])
   = Some
      ([(Expr, [N Term; N Binop; N Expr]); (Term, [N Num]); (Num, [T "3"]);
	(Binop, [T "-"]); (Expr, [N Term]); (Term, [N Num]); (Num, [T "4"])],
       ["+"; "$"; "5"; "-"; "6"]))
    ;;
    
(****************My own Tests************************)
let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None

type por_non_terminals = 
  | Frase | Verbo | Substantivo | Lixo

let por_rules =
   [Frase, [N Substantivo; N Verbo; T "."];
    Substantivo, [N Lixo; T "eu"];
    Substantivo, [ T "voce"];
    Verbo, [T "sou"];
    Verbo, [T "e"];
    Lixo, [N Lixo; N Lixo]
    ]
let por_grammar = Frase, por_rules;;
let por_new_grammar = convert_grammar por_grammar;;

let test_1 = parse_prefix por_new_grammar accept_all ["voce";"e";".";"."]
    = Some
    ([(Frase, [N Substantivo; N Verbo; T "."]); (Substantivo, [T "voce"]);
    (Verbo, [T "e"])],
    ["."])
    ;;
let test_2 = parse_prefix por_new_grammar accept_all ["voce";"voce";"e";"."]
    = None
    ;;