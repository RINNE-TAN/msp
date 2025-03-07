///|
pub(all) type! StageError {
  TypeMissmatch(expected~ : Ty, actual~ : Ty)
  CanNotInfer(term~ : Expr)
  VarNotFound(var~ : Ident)
  CrossStagePersistence(var~ : Ident)
  StageAntiControl(var~ : Ident)
  ArgNumMissmatch
  CircularReference
} derive(Show)
