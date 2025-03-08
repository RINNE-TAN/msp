///|
fn main {
  match @cli.cli?() {
    Ok(_) => ()
    Err(err) => println(err)
  }
}
