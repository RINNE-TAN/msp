///|
test "parser/expr" {
  let input = "1 + 2 * 3 / 4 % (6 - 7)"
  let expected : @types.Expr = EBinary(
    ENum(1),
    Add,
    EBinary(
      EBinary(EBinary(ENum(2), Mul, ENum(3)), Div, ENum(4)),
      Mod,
      EBinary(ENum(6), Sub, ENum(7)),
    ),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/if" {
  let input =
    #|if (x == 0)
    #|then x - 1
    #|else y + 1
  let expected : @types.Expr = EIf(
    EBinary(EVar("x"), Beq, ENum(0)),
    EBinary(EVar("x"), Sub, ENum(1)),
    EBinary(EVar("y"), Add, ENum(1)),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/if_nest_b0" {
  let input =
    #|if (x == 0)
    #|then if (x != 1) then 1 else 2
    #|else 3
  let expected : @types.Expr = EIf(
    EBinary(EVar("x"), Beq, ENum(0)),
    EIf(EBinary(EVar("x"), Bne, ENum(1)), ENum(1), ENum(2)),
    ENum(3),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/if_nest_b1" {
  let input =
    #|if (x > 0)
    #|then true
    #|else if (x >= 1) then false else true
  let expected : @types.Expr = EIf(
    EBinary(EVar("x"), Bgt, ENum(0)),
    EBool(true),
    EIf(EBinary(EVar("x"), Bge, ENum(1)), EBool(false), EBool(true)),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/if_nest_cond" {
  let input =
    #|if if (x <= 1) then false else true
    #|then 1
    #|else 2
  let expected : @types.Expr = EIf(
    EIf(EBinary(EVar("x"), Ble, ENum(1)), EBool(false), EBool(true)),
    ENum(1),
    ENum(2),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/assert" {
  let input =
    #|[x : (<int>, int) => (int) => bool]
  let expected : @types.Expr = Assert(
    EVar("x"),
    Arrow([Rep(Integer), Integer], Arrow([Integer], Boolean)),
  )
  assert_eq!(parse!(pexpr, input), expected)
} ///|

///|
test "parser/app_nest" {
  let input =
    #|f(a, true, 1)(c < 3, d > 4)
  let expected : @types.Expr = EApp(
    EApp(EVar("f"), [EVar("a"), EBool(true), ENum(1)]),
    [EBinary(EVar("c"), Blt, ENum(3)), EBinary(EVar("d"), Bgt, ENum(4))],
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/lam_nest" {
  let input =
    #|lambda x y z. lambda i j k. x + i 
  let expected : @types.Expr = ELam(
    ["x", "y", "z"],
    ELam(["i", "j", "k"], EBinary(EVar("x"), Add, EVar("i"))),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/let" {
  let input =
    #|let x = 1
    #|    y = 2
    #|    z = 3
    #|in 4
  let expected : @types.Expr = ELets(
    [("x", ENum(1)), ("y", ENum(2)), ("z", ENum(3))],
    ENum(4),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/let_nest" {
  let input =
    #|let x = 1
    #|    y = 2
    #|    z = 3
    #|in
    #|let i = 1
    #|    j = 2
    #|    k = 3
    #|in 4
  let expected : @types.Expr = ELets(
    [("x", ENum(1)), ("y", ENum(2)), ("z", ENum(3))],
    ELets([("i", ENum(1)), ("j", ENum(2)), ("k", ENum(3))], ENum(4)),
  )
  assert_eq!(parse!(pexpr, input), expected)
}

///|
test "parser/prog" {
  let input =
    #|id : (int) => int = 
    #|  lambda x.x
    #|add : (int, int) => int = 
    #|  lambda x y.x + y
  let expected : @types.Prog = {
    tops: [
      {
        name: "id",
        expr: ELam(["x"], EVar("x")),
        ty: Arrow([Integer], Integer),
      },
      {
        name: "add",
        expr: ELam(["x", "y"], EBinary(EVar("x"), Add, EVar("y"))),
        ty: Arrow([Integer, Integer], Integer),
      },
    ],
  }
  assert_eq!(parse!(pprog, input), expected)
}
