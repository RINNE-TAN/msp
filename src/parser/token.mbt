///|
pub(all) enum Token {
  Number(Int)
  Symbol(Symbol)
  Keyword(Keyword)
  Variable(String)
} derive(Eq, Show)

///|
pub(all) enum Symbol {
  Arrow // =>
  Eq // ==
  NE // !=
  GE // >=
  GT // >
  LE // <=
  LT // <
  Ass // =
  LParen // (
  RParen // )
  LBracket // [
  RBracket // ]
  Add // +
  Sub // -
  Mul // *
  Div // /
  Mod // %
  Dot // .
  Comma // ,
  Colon // :
} derive(Eq, Show)

///|
pub(all) enum Keyword {
  Lambda // lambda
  If // if
  Then // then
  Else // else
  True // true
  False // false
  Int // int
  Bool // bool
  Let // let
  In // in
} derive(Eq, Show)
