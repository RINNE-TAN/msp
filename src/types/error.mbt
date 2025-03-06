///|
pub(all) type! StageError {
  TypeMissmatch(expected~ : Ty, actual~ : Ty)
  CanNotInfer(term~ : Expr)
  VarNotFound(var~ : Ident)
  StageOverflow
} derive(Show)
