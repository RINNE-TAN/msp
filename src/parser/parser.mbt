///|
typealias Parser[Value] = @combinator.Parser[Token, Value]

///|
fn pkeyword(keyword : Keyword) -> Parser[Unit] {
  @combinator.pvalue(fn {
    token => if token == Keyword(keyword) { Some(()) } else { None }
  })
} ///|

///|
fn psymbol(symbol : Symbol) -> Parser[Unit] {
  @combinator.pvalue(fn {
    token => if token == Symbol(symbol) { Some(()) } else { None }
  })
}

///|
let pident : Parser[@types.Ident] = @combinator.pvalue(fn {
  token =>
    match token {
      Variable(x) => Some(x)
      _ => None
    }
})

///|
let patomic : Parser[@types.Expr] = pparen
  .or_else(pbool)
  .or_else(pnum)
  .or_else(plam)
  .or_else(plets)
  .or_else(pif)
  .or_else(passert)
  .or_else(pvar)

///|
let pparen : Parser[@types.Expr] = psymbol(LParen)
  .and_then(pexpr_deref())
  .and_then(psymbol(RParen))
  .omit_second()
  .omit_first()

///|
let pvar : Parser[@types.Expr] = pident.map(fn { x => @types.EVar(x) })

///|
let pbool : Parser[@types.Expr] = @combinator.pvalue(fn {
  token =>
    match token {
      Keyword(True) => Some(@types.EBool(true))
      Keyword(False) => Some(@types.EBool(false))
      _ => None
    }
})

///|
let pnum : Parser[@types.Expr] = @combinator.pvalue(fn {
  token =>
    match token {
      Number(i) => Some(@types.ENum(i))
      _ => None
    }
})

///|
let plam : Parser[@types.Expr] = pkeyword(Lambda)
  .and_then(pident.repeat())
  .and_then(psymbol(Dot))
  .and_then(pexpr_deref())
  .map(fn { (((_, xs), _), t) => @types.ELam(xs, t) })

///|

///|
let plets : Parser[@types.Expr] = {
  let pbind : Parser[(@types.Ident, @types.Expr)] = pident
    .and_then(psymbol(Ass))
    .and_then(pexpr_deref())
    .map(fn { ((bind, _), expr) => (bind, expr) })
  pkeyword(Let)
  .and_then(pbind.repeat())
  .and_then(pkeyword(In))
  .and_then(pexpr_deref())
  .map(fn { (((_, binds), _), t) => @types.ELets(binds, t) })
}

///|
let pif : Parser[@types.Expr] = pkeyword(If)
  .and_then(pexpr_deref())
  .and_then(pkeyword(Then))
  .and_then(pexpr_deref())
  .and_then(pkeyword(Else))
  .and_then(pexpr_deref())
  .map(fn { (((((_, cond), _), b0), _), b1) => @types.EIf(cond, b0, b1) })

///|
let passert : Parser[@types.Expr] = psymbol(LBracket)
  .and_then(pexpr_deref())
  .and_then(psymbol(Colon))
  .and_then(pty)
  .and_then(psymbol(RBracket))
  .map(fn { ((((_, expr), _), ty), _) => @types.Assert(expr, ty) })

///|
let papp : Parser[@types.Expr] = {
  let pcall = psymbol(LParen)
    .and_then(pequality.repeat_with_sep(psymbol(Comma)))
    .and_then(psymbol(RParen))
    .map(fn { ((_, args), _) => args })
  pequality
  .and_then(pcall.repeat())
  .map(fn {
    (init, tails) => tails.fold(init~, fn { f, args => @types.EApp(f, args) })
  })
}

///|
let pequality : Parser[@types.Expr] = {
  fn parithOp() -> Parser[@types.BinOp] {
    @combinator.pvalue(fn {
      token =>
        match token {
          Symbol(Eq) => Some(@types.Beq)
          Symbol(NE) => Some(@types.Bne)
          Symbol(GT) => Some(@types.Bgt)
          Symbol(GE) => Some(@types.Bge)
          Symbol(LT) => Some(@types.Blt)
          Symbol(LE) => Some(@types.Ble)
          _ => None
        }
    })
  }

  parith
  .and_then(parithOp().and_then(parith).repeat())
  .map(fn {
    (init, tails) =>
      tails.fold(init~, fn { l, (op, r) => @types.EBinary(l, op, r) })
  })
}

///|
let parith : Parser[@types.Expr] = {
  fn parithOp() -> Parser[@types.BinOp] {
    @combinator.pvalue(fn {
      token =>
        match token {
          Symbol(Add) => Some(@types.Add)
          Symbol(Sub) => Some(@types.Sub)
          _ => None
        }
    })
  }

  pcombine
  .and_then(parithOp().and_then(pcombine).repeat())
  .map(fn {
    (init, tails) =>
      tails.fold(init~, fn { l, (op, r) => @types.EBinary(l, op, r) })
  })
}

///|
let pcombine : Parser[@types.Expr] = {
  let pcombineOp : Parser[@types.BinOp] = @combinator.pvalue(fn {
    token =>
      match token {
        Symbol(Mul) => Some(@types.Mul)
        Symbol(Div) => Some(@types.Div)
        Symbol(Mod) => Some(@types.Mod)
        _ => None
      }
  })
  patomic
  .and_then(pcombineOp.and_then(patomic).repeat())
  .map(fn {
    (init, tails) =>
      tails.fold(init~, fn { l, (op, r) => @types.EBinary(l, op, r) })
  })
}

///|
let pexprRef : Ref[Parser[@types.Expr]] = Ref::new(@combinator.pfail())

///|
fn pexpr_deref() -> Parser[@types.Expr] {
  @combinator.Parser::from_ref(pexprRef)
}

///|
pub let pexpr : Parser[@types.Expr] = {
  pexprRef.val = papp
  pexpr_deref()
}

///|
let pboolean : Parser[@types.Ty] = pkeyword(Bool).map(fn { _ => @types.Boolean })

///|
let pinteger : Parser[@types.Ty] = pkeyword(Int).map(fn { _ => @types.Integer })

///|
let parrow : Parser[@types.Ty] = psymbol(LParen)
  .and_then(
    @combinator.Parser::from_ref(ptyRef).repeat_with_sep(psymbol(Comma)),
  )
  .and_then(psymbol(RParen))
  .and_then(psymbol(Arrow))
  .and_then(@combinator.Parser::from_ref(ptyRef))
  .map(fn { ((((_, argsTy), _), _), bTy) => @types.Arrow(argsTy, bTy) })

///|
let prep : Parser[@types.Ty] = psymbol(LT)
  .and_then(@combinator.Parser::from_ref(ptyRef))
  .and_then(psymbol(GT))
  .map(fn { ((_, ty), _) => @types.Rep(ty) })

///|
let ptyRef : Ref[Parser[@types.Ty]] = Ref::new(@combinator.pfail())

///|
let pty : Parser[@types.Ty] = {
  ptyRef.val = pboolean.or_else(pinteger).or_else(parrow).or_else(prep)
  @combinator.Parser::from_ref(ptyRef)
}

///|
pub fn parse[Value](p : Parser[Value], input : String) -> Value!Error {
  match p.parse(@combinator.Seq::from_array(lexer!(input)[:])) {
    Some((value, seq)) =>
      if seq.is_empty() {
        value
      } else {
        raise @types.ParserRemain(remain=seq.to_string())
      }
    None => raise @types.ParserError
  }
}
