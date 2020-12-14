use "debug"

class DefaultMalEnv
  fun calc(): MalEnv =>
    let env = MalEnv()
    env.set("+", PlusFunction)
    env.set("-", MinusFunction)
    env.set("*", MultiplyFunction)
    env.set("/", DivideFunction)
    env

// TODO: move logic here from main actor
class Mal
  let _lisp_env: MalEnv

  // TODO: on_read, on_print, on_error
  new create() =>
    _lisp_env = DefaultMalEnv.calc()
    rep("(def! not (fn* (a) (if a false true)))")

  fun read(str: String): MalType => 
    try
      let reader = Reader.create()?
      reader.read_str(str)?
    else
      Debug("Read error")
    end
  
  fun eval(ast: MalType, lisp_env: MalEnv): MalType => ast

  fun print(exp: MalType): String => 
    Printer.print_str(exp)

  fun ref rep (str: String): String => 
    print(eval(read(str), _lisp_env))