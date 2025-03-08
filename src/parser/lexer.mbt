///|
typealias Lexer[Value] = @combinator.Parser[Char, Value]

///|
fn is_ws(c : Char) -> Bool {
  c == ' ' || c == '\n' || c == '\t' || c == '\r'
}

///|
fn is_digit(c : Char) -> Bool {
  match c {
    '0'..='9' => true
    _ => false
  }
}

///|
fn is_name_start_char(c : Char) -> Bool {
  match c {
    '_' | 'a'..='z' | 'A'..='Z' => true
    _ => false
  }
}

///|
fn is_name_char(c : Char) -> Bool {
  is_name_start_char(c) || is_digit(c)
}

///|
let lnumber : Lexer[Token] = @combinator.pint.map(fn { i => Number(i) })

///|
let lsymbol : Lexer[Token] = @combinator.one_of([
  "=>", "==", "!=", ">=", ">", "<=", "<", "=", "(", ")", "[", "]", "+", "-", "*",
  "/", "%", ".", ",", ":",
]).map(fn {
  symbol =>
    match symbol {
      "=>" => Symbol(Arr) // =>
      "==" => Symbol(Eq) // ==
      "!=" => Symbol(NE) // !=
      ">=" => Symbol(GE) // >=
      ">" => Symbol(GT) // >
      "<=" => Symbol(LE) // <=
      "<" => Symbol(LT) // <
      "=" => Symbol(Ass) // =
      "(" => Symbol(LParen) // (
      ")" => Symbol(RParen) // )
      "[" => Symbol(LBracket) // [
      "]" => Symbol(RBracket) // ]
      "+" => Symbol(Add) // +
      "-" => Symbol(Sub) // -
      "*" => Symbol(Mul) // *
      "/" => Symbol(Div) // /
      "%" => Symbol(Mod) // %
      "." => Symbol(Dot) // .
      "," => Symbol(Comma) // ,
      ":" => Symbol(Colon) // :
      _ => abort("unreachable")
    }
})

///|
let lkeyword : Lexer[Token] = @combinator.one_of([
  "lambda", "if", "then", "else", "true", "false", "int", "bool",
]).map(fn {
  keyword =>
    match keyword {
      "lambda" => KeyWord(Lambda)
      "if" => KeyWord(If)
      "then" => KeyWord(Then)
      "else" => KeyWord(Else)
      "true" => KeyWord(True)
      "false" => KeyWord(False)
      "int" => KeyWord(Int)
      "bool" => KeyWord(Bool)
      _ => abort("unreachable")
    }
})

///|
let lvariable : Lexer[Token] = @combinator.pchar_such_that(is_name_start_char)
  .and_then(@combinator.pchar_such_that(is_name_char).repeat())
  .map(fn {
    (start, rest) => {
      let mut name = start.to_string()
      for c in rest {
        name += c.to_string()
      }
      Variable(name)
    }
  })

///|
let lwhite_spaces : Lexer[Token] = @combinator.pchar_such_that(is_ws)
  .repeat()
  .map(fn { _ => WS })

///|
let ltoken : Lexer[Token] = lnumber
  .or_else(lsymbol)
  .or_else(lkeyword)
  .or_else(lvariable)

///|
let ltokens : Lexer[Array[Token]] = ltoken
  .repeat_with_sep(lwhite_spaces)
  .and_then(lwhite_spaces)
  .omit_second()

///|
pub fn lexer(input : String) -> Array[Token]!Error {
  match ltokens.parse(@combinator.Seq::from_string(input)) {
    Some((tokens, seq)) =>
      if seq.is_empty() {
        tokens
      } else {
        raise @types.LexerRemain(remain=seq.to_string())
      }
    None => abort("unreachable")
  }
}
