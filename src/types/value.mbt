///|
pub(all) struct TopValue {
  name : Ident
  expr : Value
} derive(Show, Eq)

///|
pub(all) enum Value {
  VNum(Int)
  VBool(Bool)
  VClosure(Array[Ident], Comb, Env[Value])
  VCode(Effs, Ident)
} derive(Eq, Show)

///| @coverage.skip
pub fn Value::castVCode(self : Value) -> (Effs, Ident) {
  match self {
    VCode(effs, z) => (effs, z)
    _ => abort("unreachable")
  }
}

///|
pub(all) type Effs Array[(String, Comb)] derive(Eq, Show)

///|
pub impl Add for Effs with op_add(self, other) -> Effs {
  match (self, other) {
    (Effs(binds0), Effs(binds1)) =>
      binds0 + binds1.filter(fn { eff => not(binds0.contains(eff)) })
  }
}
