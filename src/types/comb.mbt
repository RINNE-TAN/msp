///|
pub(all) struct ProgComb {
  fns : Array[FnComb]
  expr : Comb
} derive(Show, Eq)

///|
pub(all) struct FnComb {
  name : Ident
  expr : Comb
} derive(Show, Eq)

///|
pub(all) enum Comb {
  CVar(Ident)
  CBool(Bool)
  CNum(Int)
  CLam(Array[Ident], Comb)
  CApp(Comb, Array[Comb])
  CLets(Array[(Ident, Comb)], Comb)
  CIf(Comb, Comb, Comb)
  CBinary(Comb, BinOp, Comb)
  Lift(Comb)
  MkLam(Array[Ident], Comb)
  MkApp(Comb, Array[Comb])
  MkLets(Array[(Ident, Comb)], Comb)
  MkIf(Comb, Comb, Comb)
  MkBinary(Comb, BinOp, Comb)
  MkArray(Array[Comb])
  MkProj(Comb, Int)
} derive(Show, Eq)
