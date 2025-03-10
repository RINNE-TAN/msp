///|
pub(all) enum Ty {
  Boolean
  Integer
  Arrow(Array[Ty], Ty)
  Rep(Ty)
  Unknown
} derive(Eq, Show)

///|
pub impl @pp.Pretty for Ty with pretty(self : Ty) {
  match self {
    Boolean => @pp.text("bool")
    Integer => @pp.text("int")
    Arrow(argsTy, bTy) =>
      @pp.char('(') +
      @pp.separate(@pp.char(',') + @pp.space, argsTy.map(@pp.pretty)) +
      @pp.char(')') +
      @pp.space +
      @pp.text("=>") +
      @pp.space +
      bTy.pretty()
    Rep(ty) => @pp.char('<') + ty.pretty() + @pp.char('>')
    Unknown => @pp.text("?")
  }
}
