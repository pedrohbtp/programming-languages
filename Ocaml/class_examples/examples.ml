(*Fun vs Function*)
fun x -> x+1;; (*Goal is to support currying*)
let f = fun x y -> x+y;; (*is equal to the below*)
let fun x -> fun y -> x+y;;

function x -> x+1;; (*Goal is pattern matching*)
function  (*matches anything and returns a number*)
    | []-> 12
    | [27] -> 13
    | _ -> 0 
    ;;
    
(*--------Types--------*)
(*discriminated union*)
(* Similar to the union in C, byt has a type field.
*)
type mytype = 
    |foo
    | bar of in
    | bar of string*int
    ;;
to create 
    foo
    bar 12
    baz("abs", 19)
    ;;
    
match v with 
    | foo -> 0
    | bar x -> x
    | baz(->y)->y
    ;;
    
type 'a option =
    | some of 'a
    | None 
;;

(*Comparison to Union type C++ - NOn discriminated Union
    This non- discriminative stays in a continuous block
    It allocates the exact size of the members of the union
    union u {
    car foo, 
    int bar,
    struct {char *s; int i;} baz;
    }
*)

(*Defining a list type from scratch*)
type á llist = 
    | Empty
    | Cons of 'a*'a llist
    ;;
let len =
    function 
    | Empty -> 0
    | Cons(_,t)-> 1+len t
    ;;

(*BAD style! Use pattern matching instead*)
let hd x::_ = x;;
let tl _::y =;;

(*It is possible to explicitly the type. Not advisable for style purposes*)
let inc x:int = x+1;;