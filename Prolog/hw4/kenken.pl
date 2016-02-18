
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
% fd_domain(Val,1,Range),
S#=Sum+Val,
add(Grid, Tail, S,Res,Range),
fd_labeling(Val).


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
S#=Mult*Val,
mult(Grid, Tail, S,Res,Range),
fd_labeling(Val).

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
(sub_elem(Val1, Val2,Res); sub_elem(Val2, Val1,Res)),
fd_labeling(Val1),
fd_labeling(Val2).


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
kenken(Size,Constraints,Grid):-
length(Grid,Size),
maplist(constraint(Size,Grid), Constraints),
rows_cols_constraint(Grid,Size).



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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Basic examples:
% Example1:
% kenken(1,[],T).
% plain_kenken(1,[],T).
% Answer: T=[[1]].
% Example2: 
% kenken(2,[],T).
% plain_kenken(2,[],T).
% Answer: T = [[1,2],[2,1]] and T = [[2,1],[1,2]]
% Example3:
% kenken(3,[],T).
% plain_kenken(3,[],T).
% Answer: A set of 12 answers 



%kenken_testcase(Size,Constraints),maplist(constraint(Size,Grid), Constraints).
%kenken_testcase(Size,Constraints),kenken(Size,Constraints,Grid).
%kenken_testcase(Size,Constraints),plain_kenken(Size,Constraints,Grid).
%kenken_testcase4(Size,Constraints),kenken(Size,Constraints,Grid).
%kenken_testcase4(Size,Constraints),maplist(constraint(Size,Grid), Constraints).




kenken_testcase(
  6,
  [
   +(11, [1-1, 2-1]),
   /(2, 1-2, 1-3),
   *(20, [1-4, 2-4]),
   *(6, [1-5, 1-6, 2-6, 3-6]),
   -(3, 2-2, 2-3),
   /(3, 2-5, 3-5),
   *(240, [3-1, 3-2, 4-1, 4-2]),
   *(6, [3-3, 3-4]),
   *(6, [4-3, 5-3]),
   +(7, [4-4, 5-4, 5-5]),
   *(30, [4-5, 4-6]),
   *(6, [5-1, 5-2]),
   +(9, [5-6, 6-6]),
   +(8, [6-1, 6-2, 6-3]),
   /(2, 6-4, 6-5)
  ]
).

kenken_testcase4Sol(
  4,
  [
   +(6, [1-1, 1-2, 2-1]),
   *(96, [1-3, 1-4, 2-2, 2-3, 2-4]),
   -(1, 3-1, 3-2),
   -(1, 4-1, 4-2),
   +(8, [3-3, 4-3, 4-4]),
   *(2, [3-4])
  ]
).

% No solution
kenken_testcase4Nosol(
  4,
  [
   /(2, 1-2, 1-3),
   *(6, [3-3, 3-4]),
   +(3, [1-1, 2-1]),
   -(3, 2-2, 2-3)
   
  ]
).

kenken(
  4,
  [
   +(6, [1-1, 1-2, 2-1]),
   *(96, [1-3, 1-4, 2-2, 2-3, 2-4]),
   -(1, 3-1, 3-2),
   -(1, 4-1, 4-2),
   +(8, [3-3, 4-3, 4-4]),
   *(2, [3-4])
  ],
  T
), write(T), nl, fail.

plain_kenken(
  4,
  [
   +(6, [1-1, 1-2, 2-1]),
   *(96, [1-3, 1-4, 2-2, 2-3, 2-4]),
   -(1, 3-1, 3-2),
   -(1, 4-1, 4-2),
   +(8, [3-3, 4-3, 4-4]),
   *(2, [3-4])
  ],
  T
), write(T), nl, fail.