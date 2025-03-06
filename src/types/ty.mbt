///|
pub(all) enum Ty {
  Unknown
  Boolean
  Integer
  Arrow(Array[Ty], Ty)
  Rep(Ty)
} derive(Eq, Show)
