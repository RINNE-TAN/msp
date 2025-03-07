///|
pub fn zip[A, B](l : Array[A], r : Array[B]) -> Array[(A, B)] {
  l.mapi(fn { idx, a => (a, r[idx]) })
}

///|
pub fn traverse[A, B](
  arr : Array[A],
  f : (A) -> B!@types.StageError
) -> Array[B]!@types.StageError {
  let res = []
  for a in arr {
    let b = f!(a)
    res.push(b)
  }
  res
}
