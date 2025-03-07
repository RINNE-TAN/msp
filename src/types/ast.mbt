///|
pub(all) struct Prog {
  fns : Array[Fn]
  expr : Expr
  ty : Ty
} derive(Show, Eq)

///|
pub(all) struct Fn {
  name : Ident
  expr : Expr
  ty : Ty
} derive(Show, Eq)

///|
pub(all) enum Expr {
  EVar(Ident)
  EBool(Bool)
  ENum(Int)
  ELam(Array[Ident], Expr)
  EApp(Expr, Array[Expr])
  ELets(Array[(Ident, Expr)], Expr)
  EIf(Expr, Expr, Expr)
  EBinary(Expr, BinOp, Expr)
  Assert(Expr, Ty)
} derive(Show, Eq)
