///|
typealias Env[A] = @types.Env[A]

///|
typealias V = @types.Value

///|
typealias In = @types.Comb

///|
pub fn evalProg(prog : @types.ProgComb) -> @types.ProgComb!Error {
  @types.ProgComb::{
    tops: @utils.mapM!(prog.tops, fn { top => evalTop!(topGamma!(prog), top) }).filter_map(fn {
        top => top
      },
    ),
  }
}

///|
fn topGamma(prog : @types.ProgComb) -> Env[V]!Error {
  let mut tops = prog.tops
  let mut topGamma = Env::empty()
  while true {
    let remainTops = tops.filter_map(fn {
      top =>
        match eval?(Env::empty(), topGamma, top.expr) {
          Ok(value) => {
            topGamma = topGamma.extend(top.name, value)
            None
          }
          Err(_) => Some(top)
        }
    })
    if remainTops == tops {
      break
    }
    tops = remainTops
  }
  if tops.is_empty() {
    topGamma
  } else {
    raise @types.CircularReference
  }
}

///|
fn evalTop(topGamma : Env[V], top : @types.TopComb) -> @types.TopComb?!Error {
  reify(eval!(Env::empty(), topGamma, top.expr)).map(fn {
    expr => @types.TopComb::{ name: top.name, expr }
  })
}

///|
fn reify(value : V) -> In? {
  match value {
    VCode(Effs(effs), x) => Some(CLets(effs, CVar(x)))
    _ => None
  }
}

///|
fn eval(gamma : Env[V], topGamma : Env[V], term : In) -> V!Error {
  match term {
    CVar(x) =>
      match gamma.get?(x) {
        Ok(value) => value
        Err(_) =>
          match topGamma.get!(x) {
            VCode(_) => VCode([], x)
            others => others
          }
      }
    CBool(b) => VBool(b)
    CNum(i) => VNum(i)
    CLam(xs, t) => VClosure(xs, t, gamma)
    CApp(f, args) => {
      let argVs = @utils.mapM!(args, fn { arg => eval!(gamma, topGamma, arg) })
      match eval!(gamma, topGamma, f) {
        VClosure(xs, t, gamma) => {
          let newGamma = @utils.zip(xs, argVs).fold(init=gamma, fn {
            gamma, (x, argV) => gamma.extend(x, argV)
          })
          eval!(newGamma, topGamma, t)
        }
        _ => abort("unreachable")
      }
    }
    CLets(binds, t) => {
      let newGamma = @utils.foldM!(binds, init=gamma, fn {
        gamma, (x, bind) => gamma.extend(x, eval!(gamma, topGamma, bind))
      })
      eval!(newGamma, topGamma, t)
    }
    CIf(cond, b0, b1) =>
      match eval!(gamma, topGamma, cond) {
        VBool(true) => eval!(gamma, topGamma, b0)
        VBool(false) => eval!(gamma, topGamma, b1)
        _ => abort("unreachable")
      }
    CBinary(l, op, r) =>
      match (eval!(gamma, topGamma, l), eval!(gamma, topGamma, r)) {
        (VNum(lV), VNum(rV)) =>
          match op {
            Add => VNum(lV + rV)
            Sub => VNum(lV - rV)
            Mul => VNum(lV * rV)
            Div => VNum(lV / rV)
            Mod => VNum(lV % rV)
            Beq => VBool(lV == rV)
            Bne => VBool(lV != rV)
            Bgt => VBool(lV > rV)
            Bge => VBool(lV >= rV)
            Blt => VBool(lV < rV)
            Ble => VBool(lV <= rV)
          }
        _ => panic()
      }
    MkBool(b) => {
      let x = @utils.fresh("b")
      VCode([(x, CBool(b))], x)
    }
    MkNum(i) => {
      let x = @utils.fresh("i")
      VCode([(x, CNum(i))], x)
    }
    MkLam(xs, t) => {
      let newGamma = xs.fold(init=gamma, fn {
        gamma, x => gamma.extend(x, VCode([], x))
      })
      let (Effs(effs), tZ) = eval!(newGamma, topGamma, t).castVCode()
      let f = @utils.fresh("f")
      VCode([(f, CLam(xs, CLets(effs, CVar(tZ))))], f)
    }
    MkApp(f, args) => {
      let (eff0, fZ) = eval!(gamma, topGamma, f).castVCode()
      let argsCode = @utils.mapM!(args, fn {
        arg => eval!(gamma, topGamma, arg).castVCode()
      })
      let x = @utils.fresh("x")
      VCode(
        argsCode.fold(init=eff0, fn { effSum, (eff, _) => effSum + eff }) +
        [(x, CApp(CVar(fZ), argsCode.map(fn { (_, argZ) => CVar(argZ) })))],
        x,
      )
    }
    MkLets(_) => abort("unfinished")
    MkIf(cond, b0, b1) => {
      let (effs, condZ) = eval!(gamma, topGamma, cond).castVCode()
      let (Effs(effs0), b0Z) = eval!(gamma, topGamma, b0).castVCode()
      let (Effs(effs1), b1Z) = eval!(gamma, topGamma, b1).castVCode()
      let x = @utils.fresh("x")
      VCode(
        effs +
        [
          (
            x,
            CIf(CVar(condZ), CLets(effs0, CVar(b0Z)), CLets(effs1, CVar(b1Z))),
          ),
        ],
        x,
      )
    }
    MkBinary(l, op, r) => {
      let (effs0, lZ) = eval!(gamma, topGamma, l).castVCode()
      let (effs1, rZ) = eval!(gamma, topGamma, r).castVCode()
      let x = @utils.fresh("x")
      VCode(effs0 + effs1 + [(x, CBinary(CVar(lZ), op, CVar(rZ)))], x)
    }
  }
}
