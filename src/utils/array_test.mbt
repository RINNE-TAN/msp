///|
test "array/zip" {
  let l = [1, 2, 3]
  let r = ["a", "b", "c"]
  let expected = [(1, "a"), (2, "b"), (3, "c")]
  assert_eq!(@utils.zip(l, r), expected)
}

///|
test "array/foldM" {
  let r = @random.new()
  let arr = Array::new()
  for i in 0..=1000 {
    arr.push(r.int())
  }
  assert_eq!(
    @utils.foldM!(arr, init=0, fn { sum, x => sum + x }),
    arr.fold(init=0, fn { sum, x => sum + x }),
  )
}

///|
test "array/mapM" {
  let r = @random.new()
  let arr = Array::new()
  for i in 0..=1000 {
    arr.push(r.int())
  }
  assert_eq!(@utils.mapM!(arr, fn { x => x * x }), arr.map(fn { x => x * x }))
}
