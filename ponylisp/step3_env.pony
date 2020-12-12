use "debug"
use "term"
use "promises"
use "collections"

class DefaultListEnv
  fun calc(): LispEnv =>
    let env = LispEnv()
    env.set("+", {(a: I64, b: I64): I64 => a + b})
    env.set("-", {(a: I64, b: I64): I64 => a - b})
    env.set("*", {(a: I64, b: I64): I64 => a * b})
    env.set("/", {(a: I64, b: I64): I64 => a / b})
    env

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let out: OutStream
  let _lisp_env: LispEnv
  
  new iso create(out': OutStream) =>
    out = out'
    _lisp_env = DefaultListEnv.calc()

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
  
  fun eval_def(a: AstTypeAndNativeFunction, b: AstTypeAndNativeFunction, lisp_env: LispEnv): AstTypeAndNativeFunction ? => 
    match a
      | let x: Symbol => 
        let result = eval(b, lisp_env)
        lisp_env.set(x.value, result)
        // we need explicit return result, because Pony returns previos version of value on assignment
        result
      else
        Debug("Expects symbol")
        error
      end

  fun eval_application(x: ListType, lisp_env: LispEnv): AstTypeAndNativeFunction => 
    if x.value.size() != 3 then
      Debug("Only functions with two arguments supported")
      None
    end

    try
      Debug("Application")
      // This is anoying - need to introduce Maybe/Either
      let operator = match x.value(0)?
        | let y: Symbol => y
        else
          Debug("Expected symbol")
          error
        end
      match operator.value
      | "def!" => 
        return eval_def(x.value(1)?, x.value(2)?, lisp_env)?
      | "let*" => 
        let new_lisp_env = LispEnv(lisp_env)
        match x.value(1)?
        | let y: ListType => 
          eval_def(y.value(0)?, y.value(1)?, new_lisp_env)?
          return eval(x.value(2)?, new_lisp_env)
        else
          Debug("Expects list")
          error
        end
      end
    end

    let temp: Array[AstTypeAndNativeFunction] = []
    for v in x.value.values() do
      temp.push(eval(v, lisp_env))
    end
    try
      Debug("Native function application")
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
        eval_application(x, lisp_env)
    | let x: Symbol => 
      try
        lisp_env.get(x.value)?
      else
        Debug("Variable not found " + x.value)
        None
      end
    | let x: NativeFunction => 
      x
    end

  fun print(exp: AstTypeAndNativeFunction): String => 
    Printer.print_str(exp)

  fun ref rep (str: String): String => 
    print(eval(read(str), _lisp_env))

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
