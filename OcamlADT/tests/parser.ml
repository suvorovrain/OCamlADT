(** Copyright 2024-2025, Rodion Suvorov, Mikhail Gavrilenko *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open Ocamladt_lib.Parser
open Ocamladt_lib.Ast

(* open Angstrom *)
let test_programm str = print_endline (show_program (parse_str str))

let%expect_test "negative int constant" =
  test_programm {|-1;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"), ((Exp_constant (Const_integer 1)), []))))
      ] |}]
;;

(*good*)
let%expect_test "positive int constant" =
  test_programm {|+1;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "+"), ((Exp_constant (Const_integer 1)), []))))
      ] |}]
;;

(*good*)
let%expect_test " nt constant" =
  test_programm {|1;;|};
  [%expect {| [(Str_eval (Exp_constant (Const_integer 1)))] |}]
;;

(*good*)
let%expect_test "whitespace befor int constant" =
  test_programm {|     1;;|};
  [%expect {| [(Str_eval (Exp_constant (Const_integer 1)))] |}]
;;

(*good*)
let%expect_test "negative zero" =
  test_programm {|-0;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"), ((Exp_constant (Const_integer 0)), []))))
      ] |}]
;;

(*good*)
let%expect_test "positive zero" =
  test_programm {|+0;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "+"), ((Exp_constant (Const_integer 0)), []))))
      ] |}]
;;

(*good*)
let%expect_test "zero" =
  test_programm {|0;;|};
  [%expect {| [(Str_eval (Exp_constant (Const_integer 0)))] |}]
;;

(*good*)
let%expect_test "substraction" =
  test_programm {|5-11;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_constant (Const_integer 11)), [])),
            [])
           )))
      ] |}]
;;

(*good*)
let%expect_test "strange move" =
  test_programm {|5=5;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "="),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_constant (Const_integer 5)), [])),
            [])
           )))
      ] |}]
;;

(*good*)
let%expect_test "(assignment)" =
  test_programm {|x = 52;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "="),
           ((Exp_tuple ((Exp_ident "x"), (Exp_constant (Const_integer 52)), [])),
            [])
           )))
      ] |}]
;;

(*good*)
let%expect_test "multiplication" =
  test_programm {|5*5;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "*"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_constant (Const_integer 5)), [])),
            [])
           )))
      ] |}]
;;

(*good*)
let%expect_test "operators with different priorities" =
  test_programm {|5-5*1;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_apply ((Exp_ident "*"),
                   ((Exp_tuple
                       ((Exp_constant (Const_integer 5)),
                        (Exp_constant (Const_integer 1)), [])),
                    [])
                   )),
                [])),
            [])
           )))
      ] |}]
;;

(*good*)
let%expect_test "operators with different priorities" =
  test_programm {|5*5-1;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"),
           ((Exp_tuple
               ((Exp_apply ((Exp_ident "*"),
                   ((Exp_tuple
                       ((Exp_constant (Const_integer 5)),
                        (Exp_constant (Const_integer 5)), [])),
                    [])
                   )),
                (Exp_constant (Const_integer 1)), [])),
            [])
           )))
      ] |}]
;;

(*good*)

let%expect_test "parenthesis with operators with different priorities" =
  test_programm {|5*(5-1);;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "*"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_apply ((Exp_ident "-"),
                   ((Exp_tuple
                       ((Exp_constant (Const_integer 5)),
                        (Exp_constant (Const_integer 1)), [])),
                    [])
                   )),
                [])),
            [])
           )))
      ] |}]
;;

let%expect_test "parenthesis3" =
  test_programm {|(5);;|};
  [%expect {| [(Str_eval (Exp_constant (Const_integer 5)))] |}]
;;

(*bad*)
let%expect_test "parenthesis1" =
  test_programm {|(5*(5-1));;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "*"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_apply ((Exp_ident "-"),
                   ((Exp_tuple
                       ((Exp_constant (Const_integer 5)),
                        (Exp_constant (Const_integer 1)), [])),
                    [])
                   )),
                [])),
            [])
           )))
      ] |}]
;;

(*bad*)
let%expect_test "parenthesis2" =
  test_programm {|( 5-1 );;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "-"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_constant (Const_integer 1)), [])),
            [])
           )))
      ] |}]
;;

(* good fr *)
let%expect_test "tuple" =
  test_programm {|(5,1);;|};
  [%expect
    {|
    [(Str_eval
        (Exp_tuple
           ((Exp_constant (Const_integer 5)), (Exp_constant (Const_integer 1)),
            [])))
      ] |}]
;;

(* good fr *)
let%expect_test "int + a" =
  test_programm {|5+'a';;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "+"),
           ((Exp_tuple
               ((Exp_constant (Const_integer 5)),
                (Exp_constant (Const_char 'a')), [])),
            [])
           )))
      ] |}]
;;

let%expect_test "let assignment" =
  test_programm {|let x = 5 in 6;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_let (Nonrecursive,
           ({ pat = (Pat_var "x"); expr = (Exp_constant (Const_integer 5)) }, []),
           (Exp_constant (Const_integer 6)))))
      ] |}]
;;

let%expect_test "let assignment with recursion" =
  test_programm {|let rec x = 5 in 6;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_let (Recursive,
           ({ pat = (Pat_var "x"); expr = (Exp_constant (Const_integer 5)) }, []),
           (Exp_constant (Const_integer 6)))))
      ] |}]
;;

(*bad*)
let%expect_test "let assignment with recursion" =
  test_programm {|let rec x = 5 in 7;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_let (Recursive,
           ({ pat = (Pat_var "x"); expr = (Exp_constant (Const_integer 5)) }, []),
           (Exp_constant (Const_integer 7)))))
      ] |}]
;;

let%expect_test "apply" =
  test_programm {|x;;|};
  [%expect {| [(Str_eval (Exp_ident "x"))] |}]
;;

let%expect_test "apply without space" =
  test_programm {|f(x);;|};
  [%expect {| [(Str_eval (Exp_apply ((Exp_ident "f"), ((Exp_ident "x"), []))))] |}]
;;

let%expect_test "apply num to ident" =
  test_programm {|f (x-1);;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "f"),
           ((Exp_apply ((Exp_ident "-"),
               ((Exp_tuple
                   ((Exp_ident "x"), (Exp_constant (Const_integer 1)), [])),
                [])
               )),
            [])
           )))
      ] |}]
;;

let%expect_test "simple fun" =
  test_programm {|fun x -> y;;|};
  [%expect {| [(Str_eval (Exp_fun (((Pat_var "x"), []), (Exp_ident "y"))))] |}]
;;

let%expect_test "multi pattern fun" =
  test_programm {|fun x z -> y;;|};
  [%expect
    {| [(Str_eval (Exp_fun (((Pat_var "x"), [(Pat_var "z")]), (Exp_ident "y"))))] |}]
;;

let%expect_test "multi fun" =
  test_programm {|fun p -> fun x -> z;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_fun (((Pat_var "p"), []),
           (Exp_fun (((Pat_var "x"), []), (Exp_ident "z"))))))
      ] |}]
;;

let%expect_test "apply and subtraction" =
  test_programm {|f (x-1);;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "f"),
           ((Exp_apply ((Exp_ident "-"),
               ((Exp_tuple
                   ((Exp_ident "x"), (Exp_constant (Const_integer 1)), [])),
                [])
               )),
            [])
           )))
      ] |}]
;;

let%expect_test "exprlet and" =
  test_programm {|let rec x x x x x x x = y and x = 20 in 5;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_let (Recursive,
           ({ pat = (Pat_var "x");
              expr =
              (Exp_fun (
                 ((Pat_var "x"),
                  [(Pat_var "x"); (Pat_var "x"); (Pat_var "x"); (Pat_var "x");
                    (Pat_var "x")]),
                 (Exp_ident "y")))
              },
            [{ pat = (Pat_var "x"); expr = (Exp_constant (Const_integer 20)) }]),
           (Exp_constant (Const_integer 5)))))
      ] |}]
;;

let%expect_test "let and tuple" =
  test_programm {|let (a,b) = (a,b);;|};
  [%expect
    {|
    [(Str_value (Nonrecursive,
        ({ pat = (Pat_tuple ((Pat_var "a"), (Pat_var "b"), []));
           expr = (Exp_tuple ((Exp_ident "a"), (Exp_ident "b"), [])) },
         [])
        ))
      ] |}]
;;

let%expect_test "let and" =
  test_programm {|let rec x x x x x x x = y and x = 20;;|};
  [%expect
    {|
    [(Str_value (Recursive,
        ({ pat = (Pat_var "x");
           expr =
           (Exp_fun (
              ((Pat_var "x"),
               [(Pat_var "x"); (Pat_var "x"); (Pat_var "x"); (Pat_var "x");
                 (Pat_var "x")]),
              (Exp_ident "y")))
           },
         [{ pat = (Pat_var "x"); expr = (Exp_constant (Const_integer 20)) }])
        ))
      ] |}]
;;

let%expect_test "multiplication and apply" =
  test_programm {|x * f x;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_apply ((Exp_ident "*"),
           ((Exp_tuple
               ((Exp_ident "x"),
                (Exp_apply ((Exp_ident "f"), ((Exp_ident "x"), []))), [])),
            [])
           )))
      ] |}]
;;

let%expect_test "let and apply" =
  test_programm {|let f x = x;;|};
  [%expect
    {|
    [(Str_value (Nonrecursive,
        ({ pat = (Pat_var "f");
           expr = (Exp_fun (((Pat_var "x"), []), (Exp_ident "x"))) },
         [])
        ))
      ] |}]
;;

let%expect_test "let and apply v2" =
  test_programm {|let fact x = fact(x-1);;|};
  [%expect
    {|
    [(Str_value (Nonrecursive,
        ({ pat = (Pat_var "fact");
           expr =
           (Exp_fun (((Pat_var "x"), []),
              (Exp_apply ((Exp_ident "fact"),
                 ((Exp_apply ((Exp_ident "-"),
                     ((Exp_tuple
                         ((Exp_ident "x"), (Exp_constant (Const_integer 1)), [])),
                      [])
                     )),
                  [])
                 ))
              ))
           },
         [])
        ))
      ] |}]
;;

let%expect_test "if then" =
  test_programm {|if 5 then 6;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_if ((Exp_constant (Const_integer 5)),
           (Exp_constant (Const_integer 6)), None)))
      ] |}]
;;

let%expect_test "if statement. condition from fact" =
  test_programm {|if n = 0 then 1 else 7;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_if (
           (Exp_apply ((Exp_ident "="),
              ((Exp_tuple ((Exp_ident "n"), (Exp_constant (Const_integer 0)), [])),
               [])
              )),
           (Exp_constant (Const_integer 1)),
           (Some (Exp_constant (Const_integer 7))))))
      ] |}]
;;

let%expect_test "let and if" =
  test_programm {|let x = if n = 0 then 6 else 7 in 6;;|};
  [%expect
    {|
    [(Str_eval
        (Exp_let (Nonrecursive,
           ({ pat = (Pat_var "x");
              expr =
              (Exp_if (
                 (Exp_apply ((Exp_ident "="),
                    ((Exp_tuple
                        ((Exp_ident "n"), (Exp_constant (Const_integer 0)), [])),
                     [])
                    )),
                 (Exp_constant (Const_integer 6)),
                 (Some (Exp_constant (Const_integer 7)))))
              },
            []),
           (Exp_constant (Const_integer 6)))))
      ] |}]
;;

let%expect_test "factorial" =
  test_programm {|let rec fact x = if x = 0 then 1 else x * fact(x-1);;|};
  [%expect
    {|
    [(Str_value (Recursive,
        ({ pat = (Pat_var "fact");
           expr =
           (Exp_fun (((Pat_var "x"), []),
              (Exp_if (
                 (Exp_apply ((Exp_ident "="),
                    ((Exp_tuple
                        ((Exp_ident "x"), (Exp_constant (Const_integer 0)), [])),
                     [])
                    )),
                 (Exp_constant (Const_integer 1)),
                 (Some (Exp_apply ((Exp_ident "*"),
                          ((Exp_tuple
                              ((Exp_ident "x"),
                               (Exp_apply ((Exp_ident "fact"),
                                  ((Exp_apply ((Exp_ident "-"),
                                      ((Exp_tuple
                                          ((Exp_ident "x"),
                                           (Exp_constant (Const_integer 1)),
                                           [])),
                                       [])
                                      )),
                                   [])
                                  )),
                               [])),
                           [])
                          )))
                 ))
              ))
           },
         [])
        ))
      ] |}]
;;
