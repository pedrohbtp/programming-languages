let computed_fixed_point_test0_a6b9b17503dcd9b5b8e8ad16da46c432 =
  computed_fixed_point (=) (fun x -> x / 2) 1000000000 = 0
let computed_fixed_point_test1_a6b9b17503dcd9b5b8e8ad16da46c432 =
  computed_fixed_point (=) (fun x -> x *. 2.) 1. = infinity
let computed_fixed_point_test2_a6b9b17503dcd9b5b8e8ad16da46c432 =
  computed_fixed_point (=) sqrt 10. = 1.
let computed_fixed_point_test3_a6b9b17503dcd9b5b8e8ad16da46c432 =
  ((computed_fixed_point (fun x y -> abs_float (x -. y) < 1.)
			 (fun x -> x /. 2.)
			 10.)
   = 1.25)
