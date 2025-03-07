///|
test "tyck/lambda" {
  let id42 = @types.Fn::{
    name: "id42",
    expr: ELam(["x"], ENum(42)),
    ty: Arrow([Integer], Integer),
  }
  let prog = @types.Prog::{
    fns: [id42],
    expr: EVar("id42"),
    ty: Arrow([Integer], Integer),
  }
  let expected = @types.ProgComb::{
    fns: [{ name: "id42", expr: CLam(["x"], CNum(42)) }],
    expr: CVar("id42"),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/app" {
  let prog = @types.Prog::{
    fns: [
      @types.Fn::{
        name: "id42",
        expr: ELam(["x"], ENum(42)),
        ty: Arrow([Integer], Integer),
      },
    ],
    expr: EApp(EVar("id42"), [ENum(13)]),
    ty: Integer,
  }
  let expected = @types.ProgComb::{
    fns: [{ name: "id42", expr: CLam(["x"], CNum(42)) }],
    expr: CApp(CVar("id42"), [CNum(13)]),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/lets" {
  let prog = @types.Prog::{
    fns: [],
    expr: ELets(
      [
        ("x0", Assert(ENum(13), Integer)),
        ("x1", EBinary(EVar("x0"), Add, EVar("x0"))),
        ("x2", EBinary(EVar("x1"), Bgt, EVar("x0"))),
      ],
      EVar("x2"),
    ),
    ty: Boolean,
  }
  let expected = @types.ProgComb::{
    fns: [],
    expr: CLets(
      [
        ("x0", CNum(13)),
        ("x1", CBinary(CVar("x0"), Add, CVar("x0"))),
        ("x2", CBinary(CVar("x1"), Bgt, CVar("x0"))),
      ],
      CVar("x2"),
    ),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/factorial" {
  let prog = @types.Prog::{
    fns: [
      @types.Fn::{
        name: "factorial",
        expr: ELam(
          ["n"],
          EIf(
            EBinary(EVar("n"), Beq, ENum(1)),
            ENum(1),
            EBinary(
              EVar("n"),
              Mul,
              EApp(EVar("factorial"), [EBinary(EVar("n"), Sub, ENum(1))]),
            ),
          ),
        ),
        ty: Arrow([Integer], Integer),
      },
    ],
    expr: EApp(EVar("factorial"), [ENum(13)]),
    ty: Integer,
  }
  let expected = @types.ProgComb::{
    fns: [
      {
        name: "factorial",
        expr: CLam(
          ["n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(1)),
            CNum(1),
            CBinary(
              CVar("n"),
              Mul,
              CApp(CVar("factorial"), [CBinary(CVar("n"), Sub, CNum(1))]),
            ),
          ),
        ),
      },
    ],
    expr: CApp(CVar("factorial"), [CNum(13)]),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power" {
  let prog = @types.Prog::{
    fns: [
      @types.Fn::{
        name: "power",
        expr: ELam(
          ["x", "n"],
          EIf(
            EBinary(EVar("n"), Beq, ENum(0)),
            Assert(ENum(1), Integer),
            EBinary(
              EVar("x"),
              Mul,
              EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Sub, ENum(1))]),
            ),
          ),
        ),
        ty: Arrow([Integer, Integer], Integer),
      },
    ],
    expr: EApp(EVar("power"), [ENum(2), ENum(13)]),
    ty: Integer,
  }
  let expected = @types.ProgComb::{
    fns: [
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            CNum(1),
            CBinary(
              CVar("x"),
              Mul,
              CApp(CVar("power"), [CVar("x"), CBinary(CVar("n"), Sub, CNum(1))]),
            ),
          ),
        ),
      },
    ],
    expr: CApp(CVar("power"), [CNum(2), CNum(13)]),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power_stage" {
  let prog = @types.Prog::{
    fns: [
      @types.Fn::{
        name: "power",
        expr: ELam(
          ["x", "n"],
          EIf(
            EBinary(EVar("n"), Beq, ENum(0)),
            ENum(1),
            EBinary(
              EVar("x"),
              Mul,
              EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Sub, ENum(1))]),
            ),
          ),
        ),
        ty: Arrow([Rep(Integer), Integer], Rep(Integer)),
      },
    ],
    expr: ELam(["input"], EApp(EVar("power"), [EVar("input"), ENum(13)])),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let expected = @types.ProgComb::{
    fns: [
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            Lift(CNum(1)),
            MkBinary(
              CVar("x"),
              Mul,
              CApp(CVar("power"), [CVar("x"), CBinary(CVar("n"), Sub, CNum(1))]),
            ),
          ),
        ),
      },
    ],
    expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power_stage_square" {
  let even = @types.Fn::{
    name: "even",
    expr: ELam(["x"], EBinary(EBinary(EVar("x"), Mod, ENum(2)), Beq, ENum(0))),
    ty: Arrow([Integer], Boolean),
  }
  let square = @types.Fn::{
    name: "square",
    expr: ELam(["x"], EBinary(EVar("x"), Mul, EVar("x"))),
    ty: Arrow([Integer], Integer),
  }
  let power = @types.Fn::{
    name: "power",
    expr: ELam(
      ["x", "n"],
      EIf(
        EBinary(EVar("n"), Beq, ENum(0)),
        ENum(1),
        EIf(
          EApp(EVar("even"), [EVar("n")]),
          EApp(EVar("square"), [
            EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Div, ENum(2))]),
          ]),
          EBinary(
            EVar("x"),
            Mul,
            EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Sub, ENum(1))]),
          ),
        ),
      ),
    ),
    ty: Arrow([Rep(Integer), Integer], Rep(Integer)),
  }
  let prog = @types.Prog::{
    fns: [even, square, power],
    expr: ELam(["input"], EApp(EVar("power"), [EVar("input"), ENum(13)])),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let expected = @types.ProgComb::{
    fns: [
      {
        name: "even",
        expr: CLam(
          ["x"],
          CBinary(CBinary(CVar("x"), Mod, CNum(2)), Beq, CNum(0)),
        ),
      },
      { name: "square", expr: CLam(["x"], CBinary(CVar("x"), Mul, CVar("x"))) },
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            Lift(CNum(1)),
            CIf(
              CApp(CVar("even"), [CVar("n")]),
              MkApp(CVar("square"), [
                CApp(CVar("power"), [
                  CVar("x"),
                  CBinary(CVar("n"), Div, CNum(2)),
                ]),
              ]),
              MkBinary(
                CVar("x"),
                Mul,
                CApp(CVar("power"), [
                  CVar("x"),
                  CBinary(CVar("n"), Sub, CNum(1)),
                ]),
              ),
            ),
          ),
        ),
      },
    ],
    expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power_stage_rep_square" {
  let even = @types.Fn::{
    name: "even",
    expr: ELam(["x"], EBinary(EBinary(EVar("x"), Mod, ENum(2)), Beq, ENum(0))),
    ty: Arrow([Integer], Boolean),
  }
  let square = @types.Fn::{
    name: "square",
    expr: ELam(["x"], EBinary(EVar("x"), Mul, EVar("x"))),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let power = @types.Fn::{
    name: "power",
    expr: ELam(
      ["x", "n"],
      EIf(
        EBinary(EVar("n"), Beq, ENum(0)),
        ENum(1),
        EIf(
          EApp(EVar("even"), [EVar("n")]),
          EApp(EVar("square"), [
            EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Div, ENum(2))]),
          ]),
          EBinary(
            EVar("x"),
            Mul,
            EApp(EVar("power"), [EVar("x"), EBinary(EVar("n"), Sub, ENum(1))]),
          ),
        ),
      ),
    ),
    ty: Arrow([Rep(Integer), Integer], Rep(Integer)),
  }
  let prog = @types.Prog::{
    fns: [even, square, power],
    expr: ELam(["input"], EApp(EVar("power"), [EVar("input"), ENum(13)])),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let expected = @types.ProgComb::{
    fns: [
      {
        name: "even",
        expr: CLam(
          ["x"],
          CBinary(CBinary(CVar("x"), Mod, CNum(2)), Beq, CNum(0)),
        ),
      },
      {
        name: "square",
        expr: MkLam(["x"], MkBinary(CVar("x"), Mul, CVar("x"))),
      },
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            Lift(CNum(1)),
            CIf(
              CApp(CVar("even"), [CVar("n")]),
              MkApp(CVar("square"), [
                CApp(CVar("power"), [
                  CVar("x"),
                  CBinary(CVar("n"), Div, CNum(2)),
                ]),
              ]),
              MkBinary(
                CVar("x"),
                Mul,
                CApp(CVar("power"), [
                  CVar("x"),
                  CBinary(CVar("n"), Sub, CNum(1)),
                ]),
              ),
            ),
          ),
        ),
      },
    ],
    expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
  }
  assert_eq!(checkProg!(prog), expected)
}
