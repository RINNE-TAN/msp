///|
test "extract_name/simple" {
  inspect!(extract_name("/path/to/file.msp"), content="file")
  inspect!(extract_name("file.msp"), content="file")
  inspect!(extract_name("my.file.msp"), content="my")
}

///|
test "extract_name/no-extension" {
  inspect!(extract_name("/path/to/file"), content="file")
  inspect!(extract_name("file"), content="file")
}
