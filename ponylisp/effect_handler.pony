use "files"

interface MallEffectHandler
  // TODO: TypeError, RuntimeError, SyntaxError
  fun err(e: (String | None))
  fun print(str: String)
  fun read_file(file_name: String): String ?

// Object that provides handlers for I/O, Error
class StandardEffectHandler is MallEffectHandler
  // var _error: (String | None) = None
  let _env: Env
  new create(env: Env) =>
    _env = env
  fun err(e: (String | None)) =>
    // temp solution
    _env.out.print(e.string())
    // _error = consume e
  fun print(str: String) =>
    _env.out.print(str)
  fun read_file(file_name: String): String ? =>
    let path = FilePath(_env.root as AmbientAuth, file_name)?
    // Debug(path.string())
    var buf = ""
    match OpenFile(path)
    | let file: File =>
      while file.errno() is FileOK do
        buf = buf + file.read_string(1024)
      end
    else
      error
    end
    buf