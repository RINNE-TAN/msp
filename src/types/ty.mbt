///|
pub(all) enum Ty {
  Unknown
  Boolean
  Integer
  Arrow(Ty, Ty)
  Arr(Array[Ty])
  Rep(Ty)
} derive(Eq, Show)
