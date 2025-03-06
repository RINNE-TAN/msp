///|
pub typealias Ident = String

///|
let counter : Ref[Int] = Ref::new(-1)

///|
pub fn fresh(str : String) -> Ident {
  counter.val += 1
  str + "_" + counter.val.to_string()
}
