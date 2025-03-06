///|
priv enum Stage {
  Static
  Dynamic
}

///|
struct StageTy {
  ty : Ty
  stage : Stage
}

///|
typealias Ty = @types.Ty

///|
typealias Env[A] = @types.Env[A]

///|
typealias In = @types.Expr

///|
typealias Out = @types.Comb

///|
typealias Err = @types.StageError

///|
pub fn checkProg(prog : @types.Prog) -> Out!Err {
  check!(Env::empty(), Env::empty(), Static, prog.expr, prog.ty)
}

///|
fn assertTy(expected~ : Ty, actual : Ty) -> Unit!Err {
  if expected != actual {
    raise @types.TypeMissmatch(expected~, actual~)
  }
}

///|
fn check(
  gamma : Env[StageTy],
  fnGamma : Env[Ty],
  stage : Stage,
  term : In,
  expected : Ty
) -> Out!Err {
  match (stage, expected) {
    (Static, Rep(ty)) => check!(gamma, fnGamma, Dynamic, term, ty)
    (Dynamic, Rep(_)) => raise @types.StageOverflow
    _ =>
      match term {
        _ => {
          let (termC, termTy) = infer!(gamma, fnGamma, stage, term)
          assertTy!(expected~, termTy)
          termC
        }
      }
  }
}

///|
fn infer(
  gamma : Env[StageTy],
  fnGamma : Env[Ty],
  stage : Stage,
  term : In
) -> (Out, Ty)!Err {
  match term {
    Assert(term, ty) => {
      let termC = check!(gamma, fnGamma, stage, term, ty)
      (termC, ty)
    }
    _ => raise @types.CanNotInfer(term~)
  }
}
