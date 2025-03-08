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
      "=>" => Symbol(Arrow) // =>
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
  "lambda", "if", "then", "else", "true", "false", "int", "bool", "let", "in",
]).map(fn {
  keyword =>
    match keyword {
      "lambda" => Keyword(Lambda)
      "if" => Keyword(If)
      "then" => Keyword(Then)
      "else" => Keyword(Else)
      "true" => Keyword(True)
      "false" => Keyword(False)
      "int" => Keyword(Int)
      "bool" => Keyword(Bool)
      "let" => Keyword(Let)
      "in" => Keyword(In)
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
let lwhite_spaces : Lexer[Unit] = @combinator.pchar_such_that(is_ws)
  .repeat()
  .map(fn { _ => () })

///|
let ltoken : Lexer[Token] = lnumber
  .or_else(lsymbol)
  .or_else(lkeyword)
  .or_else(lvariable)

///|
let ltokens : Lexer[Array[Token]] = lwhite_spaces
  .and_then(ltoken.repeat_with_sep(lwhite_spaces))
  .and_then(lwhite_spaces)
  .omit_second()
  .omit_first()

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
