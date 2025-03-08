///| @coverage.skip
pub fn cli() -> Unit!Error {
  let output = @ref.new("output")
  let paths = []
  let usage =
    #| Multi Stage Compiler!
    #| usage: 
    #|      msp <file1> -o <output>
    #|
  @arg.parse(
    [("--output", "-o", Set_string(output), "output file name")],
    fn { path => if path.ends_with(".msp") { paths.push(path) } },
    usage,
    @env.args(),
  )
  for path in paths {
    let outDir = output.val
    @fs.create_dir!(outDir)
    let filename = extract_name(path)
    let input = @fs.read_file_to_string!(path)
    let prog0 = @parser.parse!(@parser.pprog, input)
    let prog1 = @tyck.checkProg!(prog0)
    let prog2 = @eval.evalProg!(prog1)
    let outputFile = "\{outDir}/\{filename}_out.msp"
    @fs.write_string_to_file!(outputFile, prog2.pretty().to_string())
  }
}

///|
pub fn extract_name(path : String) -> String {
  let last_slash = path.last_index_of("/", from=path.length())
  let start = if last_slash >= 0 { last_slash + 1 } else { 0 }
  let name = path[start:].to_string()
  let dot_pos = name.index_of(".", from=0)
  if dot_pos >= 0 {
    name[:dot_pos].to_string()
  } else {
    name
  }
}
