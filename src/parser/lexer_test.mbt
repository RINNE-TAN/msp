///|
test "lexer/empty" {
  assert_eq!(lexer!(""), [])
}

///|
test "lexer/number" {
  assert_eq!(lexer!("123"), [Number(123)])
  assert_eq!(lexer!("-123"), [Number(-123)])
}

///|
test "lexer/keyword" {
  assert_eq!(lexer!("lambda"), [Keyword(Lambda)])
  assert_eq!(lexer!("if"), [Keyword(If)])
}

///|
test "lexer/exp" {
  assert_eq!(lexer!("(x + y) * z"), [
    Symbol(LParen),
    Variable("x"),
    Symbol(Add),
    Variable("y"),
    Symbol(RParen),
    Symbol(Mul),
    Variable("z"),
  ])
  assert_eq!(lexer!("lambda x y z.x + y + z"), [
    Keyword(Lambda),
    Variable("x"),
    Variable("y"),
    Variable("z"),
    Symbol(Dot),
    Variable("x"),
    Symbol(Add),
    Variable("y"),
    Symbol(Add),
    Variable("z"),
  ])
  assert_eq!(lexer!("if true then true else false"), [
    Keyword(If),
    Keyword(True),
    Keyword(Then),
    Keyword(True),
    Keyword(Else),
    Keyword(False),
  ])
  assert_eq!(lexer!("if x then y else z"), [
    Keyword(If),
    Variable("x"),
    Keyword(Then),
    Variable("y"),
    Keyword(Else),
    Variable("z"),
  ])
}

///|
test "lexer/type" {
  assert_eq!(lexer!("([int]) => bool"), [
    Symbol(LParen),
    Symbol(LBracket),
    Keyword(Int),
    Symbol(RBracket),
    Symbol(RParen),
    Symbol(Arrow),
    Keyword(Bool),
  ])
  assert_eq!(lexer!("([int], bool) => bool"), [
    Symbol(LParen),
    Symbol(LBracket),
    Keyword(Int),
    Symbol(RBracket),
    Symbol(Comma),
    Keyword(Bool),
    Symbol(RParen),
    Symbol(Arrow),
    Keyword(Bool),
  ])
}

///|
test "lexer/top" {
  assert_eq!(lexer!("id : [(int) => int] = lambda x.x"), [
    Variable("id"),
    Symbol(Colon),
    Symbol(LBracket),
    Symbol(LParen),
    Keyword(Int),
    Symbol(RParen),
    Symbol(Arrow),
    Keyword(Int),
    Symbol(RBracket),
    Symbol(Ass),
    Keyword(Lambda),
    Variable("x"),
    Symbol(Dot),
    Variable("x"),
  ])
  let input =
    #|id : (int) => int
    #|= lambda x.x
    #|
    #|main : [(int) => int]
    #|= lambda x.id(x)
  assert_eq!(lexer!(input), [
    Variable("id"),
    Symbol(Colon),
    Symbol(LParen),
    Keyword(Int),
    Symbol(RParen),
    Symbol(Arrow),
    Keyword(Int),
    Symbol(Ass),
    Keyword(Lambda),
    Variable("x"),
    Symbol(Dot),
    Variable("x"),
    Variable("main"),
    Symbol(Colon),
    Symbol(LBracket),
    Symbol(LParen),
    Keyword(Int),
    Symbol(RParen),
    Symbol(Arrow),
    Keyword(Int),
    Symbol(RBracket),
    Symbol(Ass),
    Keyword(Lambda),
    Variable("x"),
    Symbol(Dot),
    Variable("id"),
    Symbol(LParen),
    Variable("x"),
    Symbol(RParen),
  ])
}

///|
test "lexer/ident" {
  assert_eq!(lexer!("x_ + _y * z_0 / __j__"), [
    Variable("x_"),
    Symbol(Add),
    Variable("_y"),
    Symbol(Mul),
    Variable("z_0"),
    Symbol(Div),
    Variable("__j__"),
  ])
}

///|
test "lexer/op" {
  assert_eq!(lexer!("x + y - z * i / j % k == >= <= << >> = != "), [
    Variable("x"),
    Symbol(Add),
    Variable("y"),
    Symbol(Sub),
    Variable("z"),
    Symbol(Mul),
    Variable("i"),
    Symbol(Div),
    Variable("j"),
    Symbol(Mod),
    Variable("k"),
    Symbol(Eq),
    Symbol(GE),
    Symbol(LE),
    Symbol(LT),
    Symbol(LT),
    Symbol(GT),
    Symbol(GT),
    Symbol(Ass),
    Symbol(NE),
  ])
}
