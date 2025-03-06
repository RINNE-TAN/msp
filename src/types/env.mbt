///|
pub(all) type Env[A] @immut/hashmap.T[String, A]

///|
pub impl[A : Eq] Eq for Env[A] with op_equal(self : Env[A], other : Env[A]) {
  match (self, other) {
    (Env(self), Env(other)) =>
      self.iter().all(fn(kv) { other[kv.0].map_or(false, fn(v) { v == kv.1 }) }) &&
      self.size() == other.size()
  }
}

///|
pub impl[A : Show] Show for Env[A] with to_string(self) {
  match self {
    Env(f) => f.to_string()
  }
}

///|
pub impl[A : Show] Show for Env[A] with output(self, logger) {
  match self {
    Env(f) => f.output(logger)
  }
}

///|
pub fn Env::empty[A]() -> Env[A] {
  @immut/hashmap.new()
}

///|
pub fn Env::get[A](self : Env[A], x : Ident) -> A!StageError {
  match self {
    Env(f) =>
      match f[x] {
        Some(v) => v
        None => raise VarNotFound(var=x)
      }
  }
}

///|
pub fn Env::extend[A](self : Env[A], x : Ident, value : A) -> Env[A] {
  match self {
    Env(f) => Env(f.add(x, value))
  }
}
