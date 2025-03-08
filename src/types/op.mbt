///|
pub(all) enum BinOp {
  Add
  Sub
  Mul
  Div
  Mod
  Beq
  Bne
  Bgt
  Bge
  Blt
  Ble
} derive(Eq, Show)

///|
pub impl @pp.Pretty for BinOp with pretty(self : BinOp) {
  match self {
    Add => @pp.text("+")
    Sub => @pp.text("-")
    Mul => @pp.text("*")
    Div => @pp.text("/")
    Mod => @pp.text("%")
    Beq => @pp.text("==")
    Bne => @pp.text("!=")
    Bgt => @pp.text(">")
    Bge => @pp.text(">=")
    Blt => @pp.text("<")
    Ble => @pp.text("<=")
  }
}
