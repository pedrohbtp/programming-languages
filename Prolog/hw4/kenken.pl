
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




% Add constraint using GNU finite domain
%add(El,[Head|Tail],Sum,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: add([[1,2],[4,3]], [1-1],0,Res)
% The result should be Sum = 1
% Example2: add([[1,2],[4,3]], [1-1,1-2],0,Res)
% The result should be Sum = 3
add(_,[],Sum,Sum). % Base case
add(Grid,[Head|Tail],Sum,Res):-
%notrace,
element(Head,Grid,Val),
%trace,
S#=Sum+Val,
add(Grid, Tail, S,Res).


%mult(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Example1: mult([[1,2],[4,3]], [1-1],Res).
% The result should be Sum = 1
% Example2: mult([[1,2],[4,3]], [1-1,1-2],Res).
% The result should be Sum = 2
mult(_,[],Mult,Mult). % Base case
mult(Grid,[Head|Tail],Mult,Res):-
%notrace,
element(Head,Grid,Val),
%trace,
S#=Mult*Val,
mult(Grid, Tail, S,Res).

% Succeeds if Ele1/Ele2 = Res or Ele2/Ele1 = Res
%div(El,[Head|Tail],Mult,Res)
% El: 
% [Head|Tail]: List with elements like [1-2,3-4]
% Description: Succeeds if either 
% Example: sub([[1,2],[4,3]],[1-1],[1-2],Res).
% The result should be Res = -1, Res = 1
division(Ele1, Ele2,Res):-Res is Ele1/Ele2.
div(Grid,[Ele_1_indx],[Ele_2_indx],Res):-
%notrace,
%trace,
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
%trace,
(division(Val1, Val2,Res); division(Val2, Val1,Res)).

% Subtaction predicate
sub_elem(Ele1, Ele2,Res):-Res is Ele1-Ele2.
sub(Grid,[Ele_1_indx],[Ele_2_indx],Res):-
%notrace,
%trace,
element(Ele_1_indx,Grid,Val1),
element(Ele_2_indx, Grid, Val2),
%trace,
(sub_elem(Val1, Val2,Res); sub_elem(Val2, Val1,Res)).


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



%Checks if the elements are unique
% Example1: elements_unique([1,2,3]). yes
% Example2: elements_unique([1,2,2]). no
elements_unique([]).
elements_unique([Head|Tail]):-
%trace,
\+ member(Head,Tail),
elements_unique(Tail).

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
%Example: good_grid_bounds([[1,2],[2,1]],2). yes
%Example2: good_grid_bounds(Grid,2). Loops over
rows_grid_bounds([],_).
rows_grid_bounds([Head|Tail],N):-
good_list(Head,N),
rows_grid_bounds(Tail,N).

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Functions used for Plain kenken
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
trace,
length(List,Len),
elements_in_range_plain(List,Len),
elements_unique(List).


% Finds missing values from 1 to N in a list
% find_missing([],[]).
% find_missing([X,Y|Ls],Out):-


% Check if a number in the grid goes from 
% 1 to N
% row_valid(Grid, El_index,N):-
% element(El_index,Grid,Val),
% fd_domain(A,1,N)



%%%% Tests
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


%kenken(N,C,T):-
