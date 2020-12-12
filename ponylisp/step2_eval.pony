use "term"
use "promises"
use "collections"
use "debug"

class DefaultListEnv
  fun calc(): LispEnv =>
    let env = LispEnv(4)
    env("+") = {(a: I64, b: I64): I64 => a + b}
    env("-") = {(a: I64, b: I64): I64 => a - b}
    env("*") = {(a: I64, b: I64): I64 => a * b}
    env("/") = {(a: I64, b: I64): I64 => a / b}
    env

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let out: OutStream
  
  new iso create(out': OutStream) =>
    out = out'

  fun ref apply(line: String, prompt: Promise[String]) =>
    try
      Tokenizer.tokenize(line)?
    end
    out.print(rep(line))
    // can't use "\n" here
    prompt("user>")

  fun ref tab(line: String): Seq[String] box => Array[String]

  fun read(str: String): AstTypeAndNativeFunction => 
    try
      let reader = Reader.create()?
      reader.read_str(str)?
    else
      Debug("Read error")
      None
    end
  
  fun eval(ast: AstTypeAndNativeFunction, lisp_env: LispEnv): AstTypeAndNativeFunction => 
    match ast
    | None => None
    | let x: Bool => x
    | let x: I64 => x
    | let x: F64 => x
    | let x: String => x
    | let x: Keyword => x
    | let x: VectorType => 
      let temp: Array[AstTypeAndNativeFunction] = []
      for v in x.value.values() do
        temp.push(eval(v, lisp_env))
      end
      VectorType(temp)
    | let x: MapType => 
      let temp = Map[String, AstTypeAndNativeFunction](x.value.size())
      for (k, v) in x.value.pairs() do
        temp(k) = eval(v, lisp_env)
      end
      MapType(temp)
    | let x: ListType => 
      if x.value.size() != 3 then
        Debug("Only functions with two arguments supported")
        None
      end
      let temp: Array[AstTypeAndNativeFunction] = []
      for v in x.value.values() do
        temp.push(eval(v, lisp_env))
      end
      try
        Debug("Application")
        // This is anoying - need to introduce Maybe/Either
        let fn = match temp(0)?
          | let y: NativeFunction => y
          else
            Debug("Expected function")
            error
          end
        let a = match temp(1)? 
          | let y: I64 => y
          else
            Debug("Expected number as first agument")
            error
          end
        let b = match temp(2)? 
          | let y: I64 => y
          else
            Debug("Expected number as second agument")
            error
          end
          fn.apply(a, b)
        else
          None
        end
      // ListType(temp)
    | let x: Symbol => 
      try
        lisp_env(x.value)?
      else
        Debug("Variable not found " + x.value)
        None
      end
    | let x: NativeFunction => 
      x
    end

  fun print(exp: AstTypeAndNativeFunction): String => 
    Printer.print_str(exp)

  fun rep (str: String): String => 
    print(eval(read(str), DefaultListEnv.calc()))

actor Main
  new create(env: Env) =>
    let handler = Handler(env.out)
    let readline = Readline(consume handler, env.out)
    let term = ANSITerm(consume readline, env.input)
    term.prompt("user> ")

    let notify = object iso
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end

    env.input(consume notify)
