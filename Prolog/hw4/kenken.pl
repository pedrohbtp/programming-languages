
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shared predicates between kenken and plain kenken
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grabs the nth element of the datamatrix
% Indexing in prolog starts with 1
% An example: element(1-1,[[1,2],[4,3]],Val).
% Returns Val = 1
element(R-C,Grid,Val):-
nth(R,Grid,Row),
nth(C,Row,Val).

% Grabs the a row of the list 
elementT(R-C,Grid,Val):-
nth(R,Grid,Val).


%Checks if the elements are unique
% Example1: elements_unique([1,2,3]). yes
% Example2: elements_unique([1,2,2]). no
elements_unique([]).
elements_unique([Head|Tail]):-
%trace,
\+ member(Head,Tail),
elements_unique(Tail).


% Transpose the Grid so we don't have to
% make a predicate special for the cols
% Example: transpose([[1,2],[3,4]],Ts).
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% GNU finite domain predicates used in kenken
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add constraint using GNU finite domain
%add(El,[Head|Tail],Sum,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: add([[1,2],[4,3]], [1-1],0,Res,4)
% The result should be Sum = 1
% Example2: add([[1,2],[4,3]], [1-1,1-2],0,Res,4)
% The result should be Sum = 3
% Example3 : add(Grid, [1-1,1-2],0,2,2).
add(_,[],Sum,Sum,Range). % Base case
add(Grid,[Head|Tail],Sum,Res,Range):-
%notrace,
element(Head,Grid,Val),
fd_domain(Val,1,Range),
% trace,
% fd_labeling(Val),
fd_labeling(Val),
S#=Sum+Val,
add(Grid, Tail, S,Res,Range).



%mult(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: mult([[1,2],[4,3]], [1-1],1,Res,4).
% The result should be Sum = 1
% Example2: mult([[1,2],[4,3]], [1-1,1-2],1,Res,4).
% The result should be Sum = 2
% Example3: mult(Grid, [1-1,1-2],1,2,2).
mult(_,[],Mult,Mult,Range). % Base case
mult(Grid,[Head|Tail],Mult,Res,Range):-
%notrace,
element(Head,Grid,Val),
fd_domain(Val,1,Range),
%trace,
fd_labeling(Val),
S #= Mult*Val,
mult(Grid, Tail, S,Res,Range).

% Succeeds if Ele1/Ele2 = Res or Ele2/Ele1 = Res
%div(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Description: Succeeds if either 
% Example1: div([[1,2],[4,3]],1-1,1-2,Res,4).
% The result should be Res = 2
% Example1: div(Grid,1-1,1-2,3,4).
% Answer: 
% Example: div(Grid,1-1,1-2,2,5).
% Answer: 
division(Ele1, Ele2,Res):-Res #= Ele1//Ele2, 0 is Ele1 mod Ele2.
div(Grid,Ele_1_indx,Ele_2_indx,Res,Range):-
%notrace,
%trace,
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
fd_domain(Val1,1,Range),
fd_domain(Val2,1,Range),
fd_labeling(Val1),
fd_labeling(Val2),
(division(Val1, Val2,Res); division(Val2, Val1,Res)).

% Subtaction predicate
% Example: sub([[1,2],[4,3]],1-1,1-2,Res,4).
% Example2: sub(Grid,1-1,1-2,3,4).
sub_elem(Ele1, Ele2,Res):-Res #= Ele1-Ele2.
sub(Grid,Ele_1_indx,Ele_2_indx,Res,Range):-
%notrace,
%trace,
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
fd_domain(Val1,1,Range),
fd_domain(Val2,1,Range),
%trace,
fd_labeling(Val1),
fd_labeling(Val2),
(sub_elem(Val1, Val2,Res); sub_elem(Val2, Val1,Res)).

% Restrict domain for the rows and columns for kenken
% Example: rows_restrict_domain(A,2).
% Answer: A = [] ? ; A = [[_#2(1..2),_#19(1..2)]] ? ; and goes on
rows_restrict_domain([],Len).
rows_restrict_domain([Head|Tail],Len):-
length(Head,Len),
%trace,
fd_all_different(Head),
fd_domain(Head,1,Len),
rows_restrict_domain(Tail,Len).

% Restricts the domain both for the rows and for the cols
% Example: rows_cols_restrict_domain(Grid,2).
% Answer: Grid = [[_#2(1..2),_#19(1..2)],[_#48(1..2),_#65(1..2)]]
% Example: fd_set_vector_max(255),rows_cols_restrict_domain(Grid,1).
% Answer: 
% Example: rows_cols_restrict_domain(Grid,4),sub(Grid,1-1,1-2,3,4).
% Answer: Grid = [[4,1,_#48(2..3),_#77(2..3)],[_#142(1..3),_#159(2..4),_#188(1..4),_#217(1..4)],[_#282(1..3),_#299(2..4),_#328(1..4),_#357(1..4)],[_#422(1..3),_#439(2..4),_#468(1..4),_#497(1..4)]]
% Example:rows_cols_restrict_domain(Grid,3),add(Grid, [1-1,1-2],0,4,3).
% Answer: Grid = [[3,1,2],[_#89(1..2),_#106(2..3),_#135(1:3)],[_#176(1..2),_#193(2..3),_#222(1:3)]]
% Should not display 2,2 in one of the answers!!!
% Example: rows_cols_restrict_domain(Grid,2),div(Grid,1-1,1-2,1,2).
% Answer: no

rows_cols_restrict_domain(Grid,Len):-
length(Grid,Len),
rows_restrict_domain(Grid,Len),
transpose(Grid,Ts),
rows_restrict_domain(Ts,Len).
%rows_restrict_domain(Ts).

% Labels all the remaining squares
% Example: rows_cols_restrict_domain(Grid,2), label(Grid).
% Answer: Grid = [[1,2],[2,1]] and Grid = [[2,1],[1,2]]
label([]).
label([Head|Tail]):-
fd_labeling(Head),
label(Tail).


% Checks if the elements are from 1 to Len
% Example1: elements_in_range([1,2,3],3). yes
% Example2: elements_in_range([1,2,3],2). no
% Example3: elements_in_range(X,3). infinite loop
elements_in_range([],_).
elements_in_range([Head|Tail],Len):-
%trace,
fd_domain(Head,1,Len), %If element is in range(1,Len)
fd_labeling(Head),
elements_in_range(Tail,Len).

% Test if all elements of the list are in 
% the range of 1 to N and are unique and the list
% has size N
% Example1: good_list([1,2,3],3). yes
% Example2: good_list([1,2,3,3],3). no
% Example3: good_list([1,3,3,4],4). no
% Example4: good_list(X,2). Loops over all the possibilities 
good_list(List,Len):-
%trace,
length(List,Len),
elements_in_range(List,Len),
elements_unique(List).

% Checks if all the rows in a matrix
% have values between 1 and N
%Example: rows_grid_bounds([[1,2],[2,1]],2). yes
%Example2: rows_grid_bounds(Grid,2). Loops over
rows_grid_bounds([],_).
rows_grid_bounds([Head|Tail],N):-
good_list(Head,N),
rows_grid_bounds(Tail,N).

% NOT USED IN THIS KENKEN
% Tests if the rows of the grid go from 0 to Len and there are no repeated 
% numbers and the numbers in the Cols of the Grid go from 1 to Len and there are 
% no repeated numbers.
% Example: rows_cols_constraint(Grid,1).
% Grid = [[1]]
rows_cols_constraint(Grid,Len):-
length(Grid,Len),
rows_grid_bounds(Grid,Len),
transpose(Grid,Ts),
rows_grid_bounds(Ts,Len).


% Grouping all constraints in a big predicate
% Example: constraint(6,Grid,11+[1-1, 2-1]).
% Answer: Grid = [[6|_],[5|_],_,_,_,_]
% Example: constraint(6,Grid,/(2, 1-2, 1-3)).
% Answer: Grid = [[_,2,1|_],_,_,_,_,_]
% Example: constraint(6,Grid,20*[1-4, 2-4]).
% Answer: Grid = [[_,_,_,5|_],[_,_,_,4|_],_,_,_,_]
% Example: constraint(6,Grid,-(3, 2-2, 2-3)).
% Answer: Grid = [_,[_,4,1|_],_,_,_,_]
constraint(Size,Grid,Constraint):-length(Grid,Size),match(Constraint,Grid,Size).
match(Res+(ListIndx),Grid,Size):-add(Grid,ListIndx,0,Res,Size).
match(Res*(ListIndx),Grid,Size):-mult(Grid,ListIndx,1,Res,Size).
match(-(Res,Ind1,Ind2),Grid,Size):-sub(Grid,Ind1,Ind2,Res,Size).
match(/(Res,Ind1,Ind2),Grid,Size):-div(Grid,Ind1,Ind2,Res,Size).

% Actual predicate to solve kenken
% The constraints must be given in this case
kenken(Size,Constraints,Grid):-
length(Grid,Size),
rows_cols_restrict_domain(Grid,Size),
maplist(constraint(Size,Grid), Constraints),
label(Grid),
rows_cols_constraint(Grid,Len).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Predicates used for Plain kenken
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add constraint using GNU finite domain
%add(El,[Head|Tail],Sum,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: add_plain([[1,2],[4,3]], [1-1],0,Res)
% The result should be Sum = 1
% Example2: add_plain([[1,2],[4,3]], [1-1,1-2],0,Res,4)
% The result should be Sum = 3
%Example3: add_plain(Grid, [1-1,1-2],0,2,2).
%Grid = [[1,1|_]|_] and continues
add_plain(_,[],Sum,Sum,Range). % Base case
add_plain(Grid,[Head|Tail],Sum,Res,Range):-
between(1,Range,Val),
element(Head,Grid,Val),
S is Sum+Val,
add_plain(Grid, Tail, S,Res,Range).


%mult(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: mult_plain([[1,2],[4,3]], [1-1],1,Res).
% The result should be Sum = 1
% Example2: mult_plain([[1,2],[4,3]], [1-1,1-2],1,Res).
% The result should be Sum = 2
% Example3: mult_plain(Grid, [1-1,1-2],1,2,2).
mult_plain(_,[],Mult,Mult,Range). % Base case
mult_plain(Grid,[Head|Tail],Mult,Res,Range):-
%notrace,
between(1,Range,Val),
element(Head,Grid,Val),
%trace,
S is Mult*Val,
mult_plain(Grid, Tail, S,Res,Range).

% Succeeds if Ele1/Ele2 = Res or Ele2/Ele1 = Res
%div(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Description: Succeeds if either 
% Example: div_plain([[1,2],[4,3]],1-1,1-2,Res).
% The result should be Res = 2 Res=0.5
% Example1: div_plain(Grid,1-1,1-2,3,4).
% Answer:Grid =  [[3,1|_]|_] and continues
division_plain(Ele1, Ele2,Res):-Res is Ele1//Ele2, 0 is Ele1 mod Ele2.
div_plain(Grid,Ele_1_indx,Ele_2_indx,Res,Range):-
%notrace,
%trace,
between(1,Range,Val1),
between(1,Range,Val2),
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
%trace,
(division_plain(Val1, Val2,Res); division_plain(Val2, Val1,Res)).

% Subtaction predicate
% Example: sub_plain([[1,2],[4,3]],1-1,1-2,Res,4).
% Example2: sub_plain(Grid,1-1,1-2,3,4).
sub_elem_plain(Ele1, Ele2,Res):-Res is Ele1-Ele2.
sub_plain(Grid,Ele_1_indx,Ele_2_indx,Res,Range):-
%notrace,
%trace,
between(1,Range,Val1),
between(1,Range,Val2),
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
%trace,
(sub_elem_plain(Val1, Val2,Res); sub_elem_plain(Val2, Val1,Res)).


% Checks if the elements are from 1 to Len
% Example1: elements_in_range_plain([1,2,3],3). yes
% Example2: elements_in_range_plain([1,2,3],2). no
% Example3: elements_in_range_plain(X,3). infinite loop
elements_in_range_plain([],_).
elements_in_range_plain([Head|Tail],Len):-
%trace,
between(1,Len,Head),
elements_in_range_plain(Tail,Len).



% Checks if all the rows in a matrix
% have values between 1 and N
%Example: good_grid_bounds_plain([[1,2],[2,1]],2). yes
%Example2: good_grid_bounds_plain(Grid,2). Loops over
rows_grid_bounds_plain([],_).
rows_grid_bounds_plain([Head|Tail],N):-
good_list_plain(Head,N),
rows_grid_bounds_plain(Tail,N).


%In range plain
% Checks if the elements are from 1 to Len
% Example1: elements_in_range_plain([1,2,3],3). yes
% Example2: elements_in_range_plain([1,2,3],2). no
% Example3: elements_in_range_plain(X,3). infinite loop
elements_in_range_plain([],_).
elements_in_range_plain([Head|Tail],Len):-
%trace,
between(1,Len,Head),
elements_in_range_plain(Tail,Len).



% Test if all elements of the list are in 
% the range of 1 to N and are unique and the list
% has size N
% Example1: good_list_plain([1,2,3],3). yes
% Example2: good_list_plain([1,2,3,3],3). no
% Example3: good_list_plain([1,3,3,4],4). no
% Example4: good_list_plain(X,2). Loops over all the possibilities 
good_list_plain(List,Len):-
%trace,
length(List,Len),
elements_in_range_plain(List,Len),
elements_unique(List).


% Tests if the rows of the grid go from 0 to Len and there are no repeated 
% numbers and the numbers in the Cols of the Grid go from 1 to Len and there are 
% no repeated numbers.
% Example: rows_cols_constraint_plain(Grid,1).
% Grid = [[1]]
rows_cols_constraint_plain(Grid,Len):-
length(Grid,Len),
rows_grid_bounds_plain(Grid,Len),
transpose(Grid,Ts),
rows_grid_bounds_plain(Ts,Len).

% Grouping all constraints in a big predicate
% Example: constraint_plain(6,Grid,11+[1-1, 2-1]).
% Answer: Grid = [[6|_],[5|_],_,_,_,_]
% Example: constraint_plain(6,Grid,/(2, 1-2, 1-3)).
% Answer: Grid = [[_,2,1|_],_,_,_,_,_]
% Example: constraint_plain(6,Grid,20*[1-4, 2-4]).
% Answer: Grid = [[_,_,_,5|_],[_,_,_,4|_],_,_,_,_]
% Example: constraint_plain(6,Grid,-(3, 2-2, 2-3)).
% Answer: Grid = [_,[_,4,1|_],_,_,_,_]
constraint_plain(Size,Grid,Constraint):-length(Grid,Size),match_plain(Constraint,Grid,Size).
match_plain(Res+(ListIndx),Grid,Size):-add_plain(Grid,ListIndx,0,Res,Size).
match_plain(Res*(ListIndx),Grid,Size):-mult_plain(Grid,ListIndx,1,Res,Size).
match_plain(-(Res,Ind1,Ind2),Grid,Size):-sub_plain(Grid,Ind1,Ind2,Res,Size).
match_plain(/(Res,Ind1,Ind2),Grid,Size):-div_plain(Grid,Ind1,Ind2,Res,Size).


% Actual predicate to solve kenken
plain_kenken(Size,Constraints,Grid):-
length(Grid,Size),
maplist(constraint_plain(Size,Grid), Constraints),
rows_cols_constraint_plain(Grid,Size).

