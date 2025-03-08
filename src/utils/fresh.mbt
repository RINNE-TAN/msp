///|
struct Fresher {
  counter : Ref[Int]
}

///|
pub fn Fresher::new() -> Fresher {
  Fresher::{ counter: Ref::new(-1) }
}

///|
pub fn Fresher::fresh(self : Fresher, str : String) -> @types.Ident {
  self.counter.val += 1
  str + "_" + self.counter.val.to_string()
}
