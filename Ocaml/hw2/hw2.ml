(*HW2*)
(******* Auxiliary functions **********)
(*Defining Non-terminal and Terminal identifiers*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal
  ;;


(*Checks if element a is in list l*)
let ele_exists a l = 
    match l with
    | [] -> false
    | _::_ -> List.exists (fun x -> x = a) l
    ;;
    

(*Receives a list of tuples representing the rules of a grammar
Returns a list representing the set of all left-hand side symbols of the tuples
They are returned in order of appeareance. 
Receives: rules - List of tuples with left and right side
        set_non_terminals: set of lefthand side symbols 
        with no repetition (in form of a list)
Test:
    type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet;;
    get_list_non_terminal [] [(Snore, [T "ZZZ"]); (Quiet, []); (Grunt, [T "khrgh"]); (Shout, [T "aooogah!"])];;
Answer:  *)
let rec get_list_non_terminal set_non_terminals rules= 
    match rules with
    | [] -> []
    | h::t -> 
        (*If the element does not exist in the list of non_terminals
        then add it and continue the recursion. Else continue the recursion*)
        if not (ele_exists (fst h) set_non_terminals)
        then List.append [(fst h)] (get_list_non_terminal (List.append [(fst h)] set_non_terminals) t)
        else get_list_non_terminal set_non_terminals t
    ;;
    
(*Function used when there is no element in the list of terminals*)        
let non_terminals_set rules = get_list_non_terminal [] rules;;

(*Receives a list of rules and a non_terminal symbol
Returns the list of all left hand sides for that symbol
Receives: 
    rules - list of rules
    non_terminal_symbol: a symbol that is the left hand side for some rule
Returns: List of all right hand sides for that symbol
            *)
let rec find_list_right_hand_sides rules non_terminal_symbol = 
    match rules with 
    | [] -> []
    | h::t ->
        (*If left hand side of the rule is non_terminal_symbol, 
        then add the lefthand side to list_right_hand_sides and continue the 
        recursion,
        else continue the recursion*)
        if fst h = non_terminal_symbol
        then List.append [(snd h)] (find_list_right_hand_sides t non_terminal_symbol)
        else find_list_right_hand_sides t non_terminal_symbol
    ;;

(*Returns (non_terminal_symbol, find_list_right_hand_sides) tuple*)
let aggregate_right_side rules non_terminal_symbol = 
    (non_terminal_symbol,find_list_right_hand_sides rules non_terminal_symbol) 
    ;;

(*aggregate_right_side for all symbols passed as non_terminal_list*)
let rec aggregate_right_side_all rules non_terminal_list = 
    match non_terminal_list with
    | [] -> []
    | h::t -> 
        List.append [aggregate_right_side rules h] (aggregate_right_side_all rules t)
    ;;

(*Uses the rules to get the non_terminal_list*)
let ag_rs_rules_all rules=
    aggregate_right_side_all rules (non_terminals_set rules)
    ;;


(*Receives a list of tuples and key
Finds the first tuple such that the first element of the tuple is equal to key*)
let rec search_key tup_list key =
    match tup_list with 
    | [] -> []
    | h::t -> 
        if fst h = key
        then snd h
        else search_key t key
    ;;

(*Convert Grammar
Converts grammar from HW1 style to HW2 style.
Receives: 
Returns: (a'*(a'->(a',a') symbol list list) = (expr, <fun>)
    *)
let convert_grammar grammar = 
    (fst grammar), search_key (ag_rs_rules_all (snd grammar))
    ;;


(****************************** Implementation of parse_prefix*******************************)

let rec visit_children_nodes prod_func symbols_to_match derivation_list length_frag acceptor suffix =
    (*Limits the iteration by the size of the fragment*)
    if List.length symbols_to_match > length_frag
    then None
    else
        match symbols_to_match with 
        (*No more rules to match, call acceptor*)
        | [] -> acceptor derivation_list suffix
        | htomatch::ttomatch -> 
            match htomatch with
            (*If the node is non-terminal, add symbols to the symbols to be matches and update the possible rules*)
            | N nontsymbol-> visit_node prod_func  nontsymbol (prod_func nontsymbol) ttomatch derivation_list length_frag acceptor suffix
                (*If the symbol is terminal, keep looking on the siblings *)
            | T tersymbol-> 
                match suffix with
                | [] -> None
                | hsuffix::tsuffix ->
                    (*If the next symbol to match matches the next suffix character
                    then continue*)
                    if tersymbol = hsuffix
                    then visit_children_nodes prod_func  ttomatch derivation_list length_frag acceptor tsuffix
                    (*Else, return none*)
                    else None
            

and visit_node prod_func nontsymbol rules symbols_to_match derivation_list length_frag acceptor suffix = 
    match rules with
    | [] -> None
    | hrule::trules -> 
        (*For each *)
        match (visit_children_nodes prod_func (hrule@symbols_to_match) (derivation_list@[nontsymbol,hrule]) length_frag acceptor suffix) with
        (*If for this rule, it didn't match, continue trying for the others*)
        | None -> visit_node prod_func nontsymbol trules symbols_to_match derivation_list length_frag acceptor suffix
        | result -> result
    ;;
    

        
let parse_prefix gram acceptor frag =
    visit_node (snd gram) (fst gram) ((snd gram) (fst gram)) [] [] (List.length frag) acceptor frag
    ;;
 


