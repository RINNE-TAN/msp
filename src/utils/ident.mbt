///|
let counter : Ref[Int] = Ref::new(-1)

///|
pub fn fresh(str : String) -> @types.Ident {
  counter.val += 1
  str + "_" + counter.val.to_string()
}
