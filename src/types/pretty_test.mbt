///|
test "pretty/op" {
  let ops : Array[BinOp] = [
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Beq,
    Bne,
    Bgt,
    Bge,
    Blt,
    Ble,
  ]
  let expected_strings = [
    "+", "-", "*", "/", "%", "==", "!=", ">", ">=", "<", "<=",
  ]
  for i = 0; i < ops.length(); i = i + 1 {
    inspect!(@pp.render(ops[i]), content=expected_strings[i])
  }
}

///|
test "pretty/power_stage_square" {
  let prog = @types.ProgComb::{
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
  let expected =
    #|square =
    #|  let
    #|    f_1 = lambda x.
    #|      let
    #|        x_0 = (x * x)
    #|      in x_0
    #|  in f_1
    #|
    #|main =
    #|  let
    #|    f_7 = lambda input.
    #|      let
    #|        i_0 = 1
    #|        x_1 = (input * i_0)
    #|        x_2 = square(x_1)
    #|        x_3 = (input * x_2)
    #|        x_4 = square(x_3)
    #|        x_5 = square(x_4)
    #|        x_6 = (input * x_5)
    #|      in x_6
    #|  in f_7
  assert_eq!(prog.pretty().to_string(), expected)
}

///|
test "pretty/if" {
  let prog = @types.ProgComb::{
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
                        CLets([("b_0", CBool(true))], CVar("b_0")),
                        CLets([("b_1", CBool(false))], CVar("b_1")),
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
  let expected =
    #|main =
    #|  let
    #|    f_3 = lambda input.
    #|      let
    #|        x_2 = if input
    #|          then let
    #|            b_0 = true
    #|          in b_0
    #|          else let
    #|            b_1 = false
    #|          in b_1
    #|      in x_2
    #|  in f_3
  assert_eq!(prog.pretty().to_string(), expected)
}
