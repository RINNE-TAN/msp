///|
pub(all) struct Prog {
  fns : Array[Fn]
  expr : Expr
}

///|
pub(all) struct Fn {
  name : Ident
  params : Array[Ident]
  body : Expr
  ty : Ty
}

///|
pub(all) enum Expr {
  EVar(Ident)
  EBool(Bool)
  ENum(Int)
  ELam(Ident, Expr)
  EApp(Expr, Expr)
  ELets(Array[(Ident, Expr)], Expr)
  EIf(Expr, Expr, Expr)
  EBinary(Expr, BinOp, Expr)
  EArray(Array[Expr])
  EProj(Expr, Int)
  Assert(Expr, Ty)
}
