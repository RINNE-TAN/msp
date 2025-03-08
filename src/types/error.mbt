///|
pub(all) type! StageError {
  TypeMismatch(expected~ : Ty, actual~ : Ty)
  CanNotInfer(term~ : Expr)
  VarNotFound(var~ : Ident)
  CrossStagePersistence(var~ : Ident)
  StageAntiControl(var~ : Ident)
  ArgNumMismatch
  CircularReference(vars~ : Array[Ident])
  LexerRemain(remain~ : String)
  ParserRemain(remain~ : String)
  ParserError
} derive(Show)
