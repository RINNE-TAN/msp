///|
test "eval/if" {
  let prog = @types.ProgComb::{
    tops: [
      {
        name: "main",
        expr: MkLam(["input"], MkIf(CVar("input"), MkNum(0), MkNum(1))),
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "main",
        expr: CLets(
          [
            (
              "f_3",
              CLam(
                ["input"],
                CLets(
                  [
                    (
                      "x_2",
                      CIf(
                        CVar("input"),
                        CLets([("i_0", CNum(0))], CVar("i_0")),
                        CLets([("i_1", CNum(1))], CVar("i_1")),
                      ),
                    ),
                  ],
                  CVar("x_2"),
                ),
              ),
            ),
          ],
          CVar("f_3"),
        ),
      },
    ],
  }
  assert_eq!(evalProg!(prog), expected)
}

///|
test "eval/power_stage_square" {
  let prog = @types.ProgComb::{
    tops: [
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
      },
      {
        name: "main",
        expr: MkLam(["input"], CApp(CVar("power"), [CVar("input"), CNum(13)])),
      },
    ],
  }
  let expected = @types.ProgComb::{
    tops: [
      {
        name: "square",
        expr: CLets(
          [
            (
              "f_1",
              CLam(
                ["x"],
                CLets(
                  [("x_0", CBinary(CVar("x"), Mul, CVar("x")))],
                  CVar("x_0"),
                ),
              ),
            ),
          ],
          CVar("f_1"),
        ),
      },
      {
        name: "main",
        expr: CLets(
          [
            (
              "f_7",
              CLam(
                ["input"],
                CLets(
                  [
                    ("i_0", CNum(1)),
                    ("x_1", CBinary(CVar("input"), Mul, CVar("i_0"))),
                    ("x_2", CApp(CVar("square"), [CVar("x_1")])),
                    ("x_3", CBinary(CVar("input"), Mul, CVar("x_2"))),
                    ("x_4", CApp(CVar("square"), [CVar("x_3")])),
                    ("x_5", CApp(CVar("square"), [CVar("x_4")])),
                    ("x_6", CBinary(CVar("input"), Mul, CVar("x_5"))),
                  ],
                  CVar("x_6"),
                ),
              ),
            ),
          ],
          CVar("f_7"),
        ),
      },
    ],
  }
  assert_eq!(evalProg!(prog), expected)
}

///|
test "eval/error_self_circular" {
  let prog = @types.ProgComb::{ tops: [{ name: "main", expr: CVar("main") }] }
  inspect!(evalProg?(prog), content="Err(CircularReference(vars=[\"main\"]))")
}

///|
test "eval/error_multi_circular" {
  let prog = @types.ProgComb::{
    tops: [
      { name: "a", expr: CVar("b") },
      { name: "b", expr: CVar("a") },
      { name: "c", expr: CNum(0) },
      { name: "d", expr: CLam(["x"], CVar("a")) },
    ],
  }
  inspect!(
    evalProg?(prog),
    content="Err(CircularReference(vars=[\"a\", \"b\"]))",
  )
}
