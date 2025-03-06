///|
pub(all) struct Prog {
  fns : Array[Fn]
  expr : Expr
}

///|
pub(all) struct Fn {
  name : @utils.Ident
  params : Array[@utils.Ident]
  body : Expr
  ty : Ty
}

///|
pub(all) enum Expr {
  EVar(@utils.Ident)
  EBool(Bool)
  ENum(Int)
  ELam(@utils.Ident, Expr)
  EApp(Expr, Expr)
  ELets(Array[(@utils.Ident, Expr)], Expr)
  EIf(Expr, Expr, Expr)
  EBinary(Expr, BinOp, Expr)
  EArray(Array[Expr])
  EProj(Expr, Int)
  Assert(Expr, Ty)
}

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
