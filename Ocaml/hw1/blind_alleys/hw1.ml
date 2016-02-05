
(*Checks if element a is in list l*)
let ele_exists a l = 
    match l with
    | [] -> false
    | _::_ -> List.exists (fun x -> x = a) l
    ;;

(*Checks if list a is a subset of list b*)
let rec subset la lb =
    match la with
    | [] -> true
    | head::tail -> ele_exists head lb && subset tail lb
    ;;
        
(*Checks if list a is equal to list b
This is true is list a is a subset of list b 
and list b is a subset of list a*)
let equal_sets la lb =
    subset la lb && subset lb la
    ;;
    
(*Returns the list with aUb. Union of the two lists
It might contain duplicates*)
let set_union la lb =
    List.append la lb
    ;;

(*Returns the intersection between list a and list b
May contain duplicates*)
let rec set_intersection la lb = 
    match la with
    | [] -> []
    | head::tail ->
        if ele_exists head lb 
        then set_union [head] (set_intersection tail lb)
        else set_union [] (set_intersection tail lb)
    ;;
(* use example: set_intersection [1;1;2] [1;1];;  *)

(*Returns all members of a that are not members of b*)
let rec set_diff la lb =
    match la with
    | [] -> []
    | head::tail ->
        if ele_exists head lb
        then set_union [] (set_diff tail lb)
        else set_union [head] (set_diff tail lb)
    ;;
(*Use example set_diff [1;2;3] [1;2;4];;*)   

(*Computes the fixed point for a
function f given the predicate eq and for the point x*)
let rec computed_fixed_point eq f x =
    if eq (f x) x
    then x
    else computed_fixed_point eq f (f x)
    ;;    
    
(*Example use: computed_fixed_point (=) sqrt 10. = 1.*)


(*Auxiliary function.
Receives
function f that receives only one argument
value x which is the argument of the function
value c which is the number of times the function is to 
be composed with itself*)
let rec rec_fun f x c =
    if c = 0
    then x
    else rec_fun f (f x) (c-1)
    ;;

(*Computes the periodic point for
function f fiven the predicate eq with period p with respect to x*)
let rec computed_periodic_point eq f p x =
    if eq (rec_fun f x p) x
    then x
    else computed_periodic_point eq f p (f x)
    ;;
(*Example use: computed_periodic_point (=) (fun x -> x / 2) 0 (-1) = -1;;*)

(*********Filters blind alleys*****************)


(*Defines the type symbol, which can be nonterminal or terminal*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

  
    
(*Place terminal values inside l_ok_symbols list
receive list and l_ok_symbols list
l_ok_symbols contains only the right hand part of the rule
Return type: ('a,'b) symbol list*)
let rec add_l_ok_symbols la l_ok_symbols =
    match la with
    | [] -> l_ok_symbols
    | head::tail -> 
        match head with
            | T value -> set_union (set_union l_ok_symbols [head]) (add_l_ok_symbols tail l_ok_symbols)
            | _ -> set_union l_ok_symbols (add_l_ok_symbols tail l_ok_symbols)
    ;;
(*test should be [T",";T"++"]: 
add_l_ok_symbols [N Sentence; T",";T"++"; N Conversation] [];;*)    

(*Loops over all the rules and return the list of all symbols marked as 
terminal
Return type: ('a,'b) symbol list*)  
let rec loop_rules lrules = 
    match lrules with
    | [] -> []
    | head::tail ->
        set_union (add_l_ok_symbols (snd head) [] ) (loop_rules tail)
    ;;
(*Test should return [T "ZZZ"; T "khrgh"; T "aooogah!"; T ","]
type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet;;
loop_rules [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]
    ;;
    *)

(*After completely population the l_ok_symbols list
checks the expressions to create a list of rules that should be eliminated
If all the right hands of a rule are in the list of l_ok_symbols, then it is considered 
l_ok_symbols
Receives:
    la: list of rules
    l_ok_symbols: list of right hands that are l_ok_symbols 
Returns: the blind set as a list for the current l_ok_symbols*)
let rec not_ok_rule_set la l_ok_symbols = 
    if l_ok_symbols = [] 
    then la
    else
    match la with
    | [] -> la
    | head::tail -> 
        (*If is it in the list of l_ok_symbols symbols, iterate
        if it is not, add it to the list of l_ok_symbols rules*)
        if subset (snd head) l_ok_symbols
        then not_ok_rule_set tail l_ok_symbols
        else set_union [head] (not_ok_rule_set tail l_ok_symbols)
    ;;
(*Test should return:[(Sentence, [N Quiet]); (Sentence, [N Grunt]); (Sentence, [N Shout]);
 (Conversation, [N Snore]);
 (Conversation, [N Sentence; T ","; N Conversation])]
 
not_ok_rule_set [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]
   [T "ZZZ"; T "khrgh"; T "aooogah!"; T ","]
   ;;
   *)

let ok_rules_set la l_ok_symbols = 
    set_diff la (not_ok_rule_set la l_ok_symbols)
    ;;
(*Test should return: [(Snore, [T "ZZZ"]); (Quiet, []); (Grunt, [T "khrgh"]);
 (Shout, [T "aooogah!"])]
 
ok_rules_set [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]
   [T "ZZZ"; T "khrgh"; T "aooogah!"; T ","]
   ;;
*)
    
(*Assuming the l_ok_sumbols list is full of the terminal values
loops over the list of rules eliminating rules that cannot be blind
and placing its symbol in the  list.
When cannot eliminate anymore, the resulting set is the set of blind rules
Receives: 
    la: list of rules proven to not be blind
    l_ok_symbols: list populated with l_ok_symbols symbols
    *)  
let rec update_l_ok_symbols_list la l_ok_symbols  = 
    if l_ok_symbols = [] 
    then l_ok_symbols
    else
    match la with
    | [] -> l_ok_symbols
    | head::tail -> 
        (*If the right hand side is all of ok symbols and 
        the left hand side is not in the list already
        then adds it*)
        if (subset (snd head) l_ok_symbols) && (not (subset [N (fst head)] l_ok_symbols))
        then set_union [ N ( fst head)] (update_l_ok_symbols_list tail l_ok_symbols)
        else update_l_ok_symbols_list tail l_ok_symbols
    ;;
(*Test should return: [T "ZZZ"; T "khrgh"; T "aooogah!"; T ",";N Snore,N Quiet; N Grunt; N Shout]

update_l_ok_symbols_list  
 [(Snore, [T "ZZZ"]); (Quiet, []); (Grunt, [T "khrgh"]); (Shout, [T "aooogah!"])]
 [T "ZZZ"; T "khrgh"; T "aooogah!"; T ","]
 ;;
 *)

(*Recursively call itself until new_rule_set is equal to old_rule_set
That means that it converged*)
let rec complete_ok_rule_set new_rule_set old_rule_set all_rules l_ok_symbols =
    if new_rule_set = old_rule_set
    then new_rule_set
    else
       complete_ok_rule_set 
           (ok_rules_set all_rules (update_l_ok_symbols_list
                            new_rule_set 
                            l_ok_symbols)
                            ) 
           new_rule_set 
           all_rules 
           (update_l_ok_symbols_list
                            new_rule_set 
                            l_ok_symbols)
                            (*TODO: Problem: not updating l_of_symbols here*)
    ;;
    
(*Test result:

*)    

(*Returns the rules with no blind alleys
Receives: tuple with grammar
*)
let filter_blind_alleys grammar =
    (*TODO: Stablish the list of non blind elements*)
    
    (fst grammar), complete_ok_rule_set [] (snd grammar) (snd grammar) (loop_rules (snd grammar) )
    ;;
    