///|
priv enum Stage {
  Static
  Dynamic
} derive(Show)

///|
typealias Ty = @types.Ty

///|
typealias Env[A] = @types.Env[A]

///|
typealias In = @types.Expr

///|
typealias Out = @types.Comb

///|
pub fn checkProg(prog : @types.Prog) -> @types.ProgComb!Error {
  let fnGamma = prog.fns.fold(init=Env::empty(), fn {
    gamma, f => gamma.extend(f.name, f.ty)
  })
  let fnsC = @utils.traverse!(prog.fns, fn { f => checkFn!(f, fnGamma) })
  let exprC = check!(Env::empty(), fnGamma, Static, prog.expr, prog.ty)
  @types.ProgComb::{ fns: fnsC, expr: exprC }
}

///|
fn checkFn(f : @types.Fn, fnGamma : Env[Ty]) -> @types.FnComb!Error {
  let exprC = check!(Env::empty(), fnGamma, Static, f.expr, f.ty)
  @types.FnComb::{ name: f.name, expr: exprC }
}

///|
fn assertTy(expected~ : Ty, actual : Ty) -> Unit!Error {
  if expected != actual {
    raise @types.TypeMissmatch(expected~, actual~)
  }
}

///|
fn check(
  gamma : Env[(Stage, Ty)],
  fnGamma : Env[Ty],
  n : Stage,
  term : In,
  expected : Ty
) -> Out!Error {
  match (n, expected) {
    (Static, Rep(expectedDyn)) =>
      match check?(gamma, fnGamma, Dynamic, term, expectedDyn) {
        Ok(termC) => return termC
        Err(_) => ()
      }
    _ => ()
  }
  match term {
    EBool(b) => {
      assertTy!(expected~, Boolean)
      match n {
        Static => CBool(b)
        Dynamic => Lift(CBool(b))
      }
    }
    ENum(i) => {
      assertTy!(expected~, Integer)
      match n {
        Static => CNum(i)
        Dynamic => Lift(CNum(i))
      }
    }
    ELam(xs, t) =>
      match expected {
        Arrow(xsTy, tTy) =>
          if xsTy.length() != xs.length() {
            raise @types.ArgNumMissmatch
          } else {
            let newGamma = @utils.zip(xs, xsTy).fold(init=gamma, fn {
              gamma, (x, xTy) => gamma.extend(x, (n, xTy))
            })
            let tC = check!(newGamma, fnGamma, n, t, tTy)
            match n {
              Static => CLam(xs, tC)
              Dynamic => MkLam(xs, tC)
            }
          }
        _ => raise @types.TypeMissmatch(expected~, actual=Arrow([], Unknown))
      }
    ELets(binds, t) => {
      let bindsC = []
      let mut gamma = gamma
      for bind in binds {
        let (x, term) = bind
        let (termC, termTy) = infer!(gamma, fnGamma, n, term)
        gamma = gamma.extend(x, (n, termTy))
        bindsC.push((x, termC))
      }
      let tC = check!(gamma, fnGamma, n, t, expected)
      match n {
        Static => CLets(bindsC, tC)
        Dynamic => MkLets(bindsC, tC)
      }
    }
    EIf(cond, b0, b1) => {
      let condC = check!(gamma, fnGamma, n, cond, Boolean)
      let b0C = check!(gamma, fnGamma, n, b0, expected)
      let b1C = check!(gamma, fnGamma, n, b1, expected)
      match n {
        Static => CIf(condC, b0C, b1C)
        Dynamic => MkIf(condC, b0C, b1C)
      }
    }
    _ => {
      let (termC, termTy) = infer!(gamma, fnGamma, n, term)
      assertTy!(expected~, termTy)
      termC
    }
  }
}

///|
fn infer(
  gamma : Env[(Stage, Ty)],
  fnGamma : Env[Ty],
  n : Stage,
  term : In
) -> (Out, Ty)!Error {
  match n {
    Static => ()
    Dynamic =>
      match infer?(gamma, fnGamma, Static, term) {
        Ok((termC, termTy)) =>
          match termTy {
            Rep(termDynTy) => return (termC, termDynTy)
            _ => ()
          }
        Err(_) => ()
      }
  }
  match term {
    EVar(var) =>
      match gamma.get?(var) {
        Ok((m, ty)) =>
          match (m, n) {
            (Static, Static) => (CVar(var), ty)
            (Static, Dynamic) => raise @types.CrossStagePersistence(var~)
            (Dynamic, Static) => raise @types.StageAntiControl(var~)
            (Dynamic, Dynamic) => (CVar(var), ty)
          }
        Err(_) => (CVar(var), fnGamma.get!(var))
      }
    EApp(f, args) =>
      match infer!(gamma, fnGamma, n, f) {
        (fC, Arrow(xsTy, tTy)) =>
          if args.length() != xsTy.length() {
            raise @types.ArgNumMissmatch
          } else {
            let argsC = @utils.traverse!(@utils.zip(args, xsTy), fn {
              (arg, argTy) => check!(gamma, fnGamma, n, arg, argTy)
            })
            match n {
              Static => (CApp(fC, argsC), tTy)
              Dynamic => (MkApp(fC, argsC), tTy)
            }
          }
        (_, fTy) =>
          raise @types.TypeMissmatch(expected=Arrow([], Unknown), actual=fTy)
      }
    EBinary(l, op, r) => {
      let lC = check!(gamma, fnGamma, n, l, Integer)
      let rC = check!(gamma, fnGamma, n, r, Integer)
      let resTy : Ty = match op {
        Add | Sub | Mul | Div | Mod => Integer
        Beq | Bne | Bgt | Bge | Blt | Ble => Boolean
      }
      match n {
        Static => (CBinary(lC, op, rC), resTy)
        Dynamic => (MkBinary(lC, op, rC), resTy)
      }
    }
    Assert(term, ty) => {
      let termC = check!(gamma, fnGamma, n, term, ty)
      (termC, ty)
    }
    _ => raise @types.CanNotInfer(term~)
  }
}
