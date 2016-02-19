%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file just contains examples of use of the code

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
%kenken_testcase4Sol(Size,Constraints),plain_kenken(Size,Constraints,Grid).
%kenken_testcase4Sol(Size,Constraints),kenken(Size,Constraints,Grid).
%kenken_testcase4Sol(Size,Constraints),maplist(constraint(Size,Grid), Constraints).
%kenken_testcase4NoSol(Size,Constraints),kenken(Size,Constraints,Grid).
%kenken_testcase4NoSol(Size,Constraints),maplist(constraint(Size,Grid), Constraints).

% To measure performance do the following:
% statistics, kenken_testcase4Sol(Size,Constraints),kenken(Size,Constraints,Grid), statistics.
% statistics, kenken_testcase4Sol(Size,Constraints),plain_kenken(Size,Constraints,Grid), statistics.



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
kenken_testcase4NoSol(
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