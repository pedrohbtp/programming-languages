let set_intersection_test0_a6b9b17503dcd9b5b8e8ad16da46c432 =
  equal_sets (set_intersection [] [1;2;3]) []
let set_intersection_test1_a6b9b17503dcd9b5b8e8ad16da46c432 =
  equal_sets (set_intersection [3;1;3] [1;2;3]) [1;3]
let set_intersection_test2_a6b9b17503dcd9b5b8e8ad16da46c432 =
  equal_sets (set_intersection [1;2;3;4] [3;1;2;4]) [4;3;2;1]
