///|
pub(all) struct ProgComb {
  tops : Array[TopComb]
} derive(Show, Eq)

///|
pub(all) struct TopComb {
  name : Ident
  expr : Comb
} derive(Show, Eq)

///|
pub(all) enum Comb {
  CVar(Ident)
  CBool(Bool)
  CNum(Int)
  CLam(Array[Ident], Comb)
  CApp(Comb, Array[Comb])
  CLets(Array[(Ident, Comb)], Comb)
  CIf(Comb, Comb, Comb)
  CBinary(Comb, BinOp, Comb)
  MkBool(Bool)
  MkNum(Int)
  MkLam(Array[Ident], Comb)
  MkApp(Comb, Array[Comb])
  MkLets(Array[(Ident, Comb)], Comb)
  MkIf(Comb, Comb, Comb)
  MkBinary(Comb, BinOp, Comb)
} derive(Show, Eq)

///|
pub impl @pp.Pretty for ProgComb with pretty(prog : ProgComb) {
  @pp.separate(@pp.hardline + @pp.hardline, prog.tops.map(@pp.pretty))
}

///|
pub impl @pp.Pretty for TopComb with pretty(top : TopComb) {
  @pp.text(top.name) +
  @pp.space +
  @pp.char('=') +
  @pp.nest(@pp.hardline + top.expr.pretty())
}

///|
pub impl @pp.Pretty for Comb with pretty(expr : Comb) {
  match expr {
    CVar(x) => @pp.text(x)
    CBool(b) => @pp.pretty(b)
    CNum(i) => @pp.pretty(i)
    CLam(xs, t) =>
      @pp.text("lambda") +
      @pp.space +
      @pp.separate(@pp.space, xs.map(@pp.text)) +
      @pp.char('.') +
      @pp.nest(@pp.hardline + t.pretty())
    CApp(f, args) =>
      f.pretty() +
      @pp.char('(') +
      @pp.separate(@pp.space, args.map(@pp.pretty)) +
      @pp.char(')')
    CLets(binds, t) =>
      @pp.text("let") +
      @pp.nest(
        @pp.hardline +
        @pp.separate(
          @pp.hardline,
          binds.map(fn {
            (bind, expr) =>
              @pp.text(bind) +
              @pp.space +
              @pp.char('=') +
              @pp.space +
              expr.pretty()
          }),
        ),
      ) +
      @pp.hardline +
      @pp.text("in") +
      @pp.space +
      t.pretty()
    CIf(cond, b0, b1) =>
      @pp.text("if") +
      @pp.space +
      cond.pretty() +
      @pp.nest(@pp.hardline + @pp.text("then") + @pp.space + b0.pretty()) +
      @pp.nest(@pp.hardline + @pp.text("else") + @pp.space + b1.pretty())
    CBinary(l, op, r) =>
      @pp.char('(') +
      l.pretty() +
      @pp.space +
      op.pretty() +
      @pp.space +
      r.pretty() +
      @pp.char(')')
    _ => abort("unreachable")
  }
}
