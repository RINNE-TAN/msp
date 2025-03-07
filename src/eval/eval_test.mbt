///|
test "eval/power_stage" {
  let prog = @types.ProgComb::{
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
      },
      {
        name: "main",
        expr: CLets(
          [
            (
              "f_44",
              CLam(
                ["input"],
                CLets(
                  [
                    ("i_30", CNum(1)),
                    ("x_31", CBinary(CVar("input"), Mul, CVar("i_30"))),
                    ("x_32", CBinary(CVar("input"), Mul, CVar("x_31"))),
                    ("x_33", CBinary(CVar("input"), Mul, CVar("x_32"))),
                    ("x_34", CBinary(CVar("input"), Mul, CVar("x_33"))),
                    ("x_35", CBinary(CVar("input"), Mul, CVar("x_34"))),
                    ("x_36", CBinary(CVar("input"), Mul, CVar("x_35"))),
                    ("x_37", CBinary(CVar("input"), Mul, CVar("x_36"))),
                    ("x_38", CBinary(CVar("input"), Mul, CVar("x_37"))),
                    ("x_39", CBinary(CVar("input"), Mul, CVar("x_38"))),
                    ("x_40", CBinary(CVar("input"), Mul, CVar("x_39"))),
                    ("x_41", CBinary(CVar("input"), Mul, CVar("x_40"))),
                    ("x_42", CBinary(CVar("input"), Mul, CVar("x_41"))),
                    ("x_43", CBinary(CVar("input"), Mul, CVar("x_42"))),
                  ],
                  CVar("x_43"),
                ),
              ),
            ),
          ],
          CVar("f_44"),
        ),
      },
    ],
  }
  assert_eq!(evalProg!(prog), expected)
}
