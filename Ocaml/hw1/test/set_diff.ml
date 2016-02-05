let set_diff_test0_a6b9b17503dcd9b5b8e8ad16da46c432 = equal_sets (set_diff [1;3] [1;4;3;1]) []
let set_diff_test1_a6b9b17503dcd9b5b8e8ad16da46c432 = equal_sets (set_diff [4;3;1;1;3] [1;3]) [4]
let set_diff_test2_a6b9b17503dcd9b5b8e8ad16da46c432 = equal_sets (set_diff [4;3;1] []) [1;3;4]
let set_diff_test3_a6b9b17503dcd9b5b8e8ad16da46c432 = equal_sets (set_diff [] [4;3;1]) []

