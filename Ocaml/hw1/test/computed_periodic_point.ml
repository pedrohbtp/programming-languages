let computed_periodic_point_test0_a6b9b17503dcd9b5b8e8ad16da46c432 =
  computed_periodic_point (=) (fun x -> x / 2) 0 (-1) = -1
let computed_periodic_point_test1_a6b9b17503dcd9b5b8e8ad16da46c432 =
  computed_periodic_point (=) (fun x -> x *. x -. 1.) 2 0.5 = -1.
