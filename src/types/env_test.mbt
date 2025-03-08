///|
test "env/commutative" {
  let env0 = Env::empty().extend("x", 1).extend("y", 2)
  let env1 = Env::empty().extend("y", 2).extend("x", 1)
  assert_eq!(env0, env1)
  assert_eq!(env1, env0)
}

///|
test "env/error" {
  let env0 = Env::empty().extend("x", 1).extend("y", 2)
  let env1 = Env::empty().extend("y", 2)
  assert_not_eq!(env0, env1)
  assert_not_eq!(env1, env0)
}

///|
test "env/diff" {
  let env0 = Env::empty().extend("x", 1).extend("y", 2)
  let env1 = Env::empty().extend("x", 2).extend("y", 2)
  assert_not_eq!(env0, env1)
  assert_not_eq!(env1, env0)
}
