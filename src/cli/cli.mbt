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
    fn { path => if path.has_suffix(".msp") { paths.push(path) } },
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
  let start = path.rev_find("/").map_or(0, fn(x) { x + 1 })
  let name = path.view(start_offset=start).to_string()
  name.find(".").map_or(name, fn(x) { name.view(end_offset=x).to_string() })
}
