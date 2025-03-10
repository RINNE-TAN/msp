///|
test "tyck/lambda" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
        name: "id42",
        expr: ELam(["x"], ENum(42)),
        ty: Arrow([Integer], Integer),
      },
      @types.Top::{
        name: "main",
        expr: EVar("id42"),
        ty: Arrow([Integer], Integer),
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "id42",
        expr: CLam(["x"], CNum(42)),
        ty: Arrow([Integer], Integer),
      },
      { name: "main", expr: CVar("id42"), ty: Arrow([Integer], Integer) },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/app" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
        name: "id42",
        expr: ELam(["x"], ENum(42)),
        ty: Arrow([Integer], Integer),
      },
      @types.Top::{
        name: "main",
        expr: EApp(EVar("id42"), [ENum(13)]),
        ty: Integer,
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "id42",
        expr: CLam(["x"], CNum(42)),
        ty: Arrow([Integer], Integer),
      },
      { name: "main", expr: CApp(CVar("id42"), [CNum(13)]), ty: Integer },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/lets" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
        name: "main",
        expr: ELets(
          [
            ("x0", Assert(ENum(13), Integer)),
            ("x1", EBinary(EVar("x0"), Add, EVar("x0"))),
            ("x2", EBinary(EVar("x1"), Bgt, EVar("x0"))),
          ],
          EVar("x2"),
        ),
        ty: Boolean,
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "main",
        expr: CLets(
          [
            ("x0", CNum(13)),
            ("x1", CBinary(CVar("x0"), Add, CVar("x0"))),
            ("x2", CBinary(CVar("x1"), Bgt, CVar("x0"))),
          ],
          CVar("x2"),
        ),
        ty: Boolean,
      },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/if" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
        name: "main",
        expr: ELam(["input"], EIf(EVar("input"), EBool(true), EBool(false))),
        ty: Rep(Arrow([Boolean], Boolean)),
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "main",
        expr: MkLam(["input"], MkIf(CVar("input"), MkBool(true), MkBool(false))),
        ty: Rep(Arrow([Boolean], Boolean)),
      },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/factorial" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
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
      @types.Top::{
        name: "main",
        expr: EApp(EVar("factorial"), [ENum(13)]),
        ty: Integer,
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
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
        ty: Arrow([Integer], Integer),
      },
      { name: "main", expr: CApp(CVar("factorial"), [CNum(13)]), ty: Integer },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
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
      @types.Top::{
        name: "main",
        expr: EApp(EVar("power"), [ENum(2), ENum(13)]),
        ty: Integer,
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
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
        ty: Arrow([Integer, Integer], Integer),
      },
      {
        name: "main",
        expr: CApp(CVar("power"), [CNum(2), CNum(13)]),
        ty: Integer,
      },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power_stage" {
  let prog = @types.Prog::{
    tops: [
      @types.Top::{
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
      @types.Top::{
        name: "main",
        expr: ELam(["input"], EApp(EVar("power"), [EVar("input"), ENum(13)])),
        ty: Rep(Arrow([Integer], Integer)),
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            MkNum(1),
            MkBinary(
              CVar("x"),
              Mul,
              CApp(CVar("power"), [CVar("x"), CBinary(CVar("n"), Sub, CNum(1))]),
            ),
          ),
        ),
        ty: Arrow([Rep(Integer), Integer], Rep(Integer)),
      },
      {
        name: "main",
        expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
        ty: Rep(Arrow([Integer], Integer)),
      },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}

///|
test "tyck/power_stage_square" {
  let even = @types.Top::{
    name: "even",
    expr: ELam(["x"], EBinary(EBinary(EVar("x"), Mod, ENum(2)), Beq, ENum(0))),
    ty: Arrow([Integer], Boolean),
  }
  let square = @types.Top::{
    name: "square",
    expr: ELam(["x"], EBinary(EVar("x"), Mul, EVar("x"))),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let power = @types.Top::{
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
  let main = @types.Top::{
    name: "main",
    expr: ELam(["input"], EApp(EVar("power"), [EVar("input"), ENum(13)])),
    ty: Rep(Arrow([Integer], Integer)),
  }
  let prog = @types.Prog::{ tops: [even, square, power, main] }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "even",
        expr: CLam(
          ["x"],
          CBinary(CBinary(CVar("x"), Mod, CNum(2)), Beq, CNum(0)),
        ),
        ty: Arrow([Integer], Boolean),
      },
      {
        name: "square",
        expr: MkLam(["x"], MkBinary(CVar("x"), Mul, CVar("x"))),
        ty: Rep(Arrow([Integer], Integer)),
      },
      {
        name: "power",
        expr: CLam(
          ["x", "n"],
          CIf(
            CBinary(CVar("n"), Beq, CNum(0)),
            MkNum(1),
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
        ty: Arrow([Rep(Integer), Integer], Rep(Integer)),
      },
      {
        name: "main",
        expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
        ty: Rep(Arrow([Integer], Integer)),
      },
    ],
  }
  assert_eq!(checkProg!(prog), expected)
}
