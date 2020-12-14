use "debug"
use "term"
use "promises"
use "collections"

class DefaultListEnv
  fun calc(): MalEnv =>
    let env = MalEnv()
    env.set("+", PlusFunction)
    env.set("-", MinusFunction)
    env.set("*", MultiplyFunction)
    env.set("/", DivideFunction)
    env

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let out: OutStream
  let _lisp_env: MalEnv
  
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

  fun read(str: String): MalType => 
    try
      let reader = Reader.create()?
      reader.read_str(str)?
    else
      Debug("Read error")
      None
    end
  
  fun eval_def_bang(name: MalType, value: MalType, lisp_env: MalEnv): MalType ? => 
    match name
      | let name': MalSymbol => 
        let value_evaluated = eval(value, lisp_env)
        lisp_env.set(name'.value, value)
        // we need explicit return result, because Pony returns previos version of value on assignment
        value_evaluated
      else
        out.print("Error: Expects list as the second argument")
        error
      end

  fun eval_application(x: MalList, lisp_env: MalEnv): MalType => 
    if x.value.size() < 3 then
      Debug("Only functions with two arguments supported")
      None
    end

    try
      Debug("Application")
      // This is anoying - need to introduce Maybe/Either
      let operator = match x.value(0)?
        | let y: MalSymbol => y
        else
          Debug("Expected symbol")
          error
        end
      match operator.value
      | "def!" => 
        return eval_def_bang(x.value(1)?, x.value(2)?, lisp_env)?
      | "let*" => 
        let new_lisp_env = MalEnv(lisp_env)
        match x.value(1)?
        | let y: MalList => 
          for (k, v) in y.value.pairs() do
            eval_def_bang(v, y.value(k + 1)?, new_lisp_env)?
          end
          return eval(x.value(2)?, new_lisp_env)
        else
          out.print("Error: Expects list as the second argument")
          return 
        end
      | "if" => 
        let condition  = match eval(x.value(1)?, lisp_env)
        | let y: Bool => y
        else
          out.print("Error: condition must be bool")
          error
        end
        let condition_expression = if condition then
          x.value(2)?
        else
          try x.value(3)? end
        end
        return eval(condition_expression, lisp_env)
      | "do" =>
        return for v in x.value.values() do
          eval(v, lisp_env)
        end
      | "fn*" => 
        let arguments = match x.value(1)?
        | let z: MalList => z
        else
          out.print("Error: Expected list as second argument") 
          return
        end
        match DecodeArray.symbol(arguments.getValue())
        | let e: NFError => 
          out.print("Error: " + e())
          return
        | let a: NFSuccess[Array[MalSymbol]] => 
          return MalLambda(a(), x.value(2)?, lisp_env) 
        end
      end
    end

    // Iter + https://tutorial.ponylang.io/expressions/partial-application.html
    let temp: Array[MalType] = []
    for v in x.value.values() do
      temp.push(eval(v, lisp_env))
    end
    try
      Debug("Native function application")
      match temp(0)?
        | let fn: NativeFunction =>
          match fn.apply(temp.slice(1))
          | let e: NFError => out.print("Error: " + e()) 
          | let a: NFSuccess[MalType] => a()
          end
        | let fn: MalLambda =>
          let new_lisp_env = MalEnv(fn.lisp_env)
          for (k, v) in fn.arguments.pairs() do
            eval_def_bang(v, temp(k + 1)?, new_lisp_env)?
          end
          eval(fn.body, new_lisp_env)
      else
        out.print("Error: expected function")
      end
    end

  fun eval(ast: MalType, lisp_env: MalEnv): MalType => 
    match ast
    | None => None
    | let x: Bool => x
    | let x: I64 => x
    | let x: F64 => x
    | let x: String => x
    | let x: MalKeyword => x
    | let x: MalVector => 
      let temp: Array[MalType] = []
      for v in x.value.values() do
        temp.push(eval(v, lisp_env))
      end
      MalVector(temp)
    | let x: MalMap => 
      let temp = Map[String, MalType](x.value.size())
      for (k, v) in x.value.pairs() do
        temp(k) = eval(v, lisp_env)
      end
      MalMap(temp)
    | let x: MalList => eval_application(x, lisp_env)
    | let x: MalSymbol => 
      try
        lisp_env.get(x.value)?
      else
        out.print("Error: Variable not found " + x.value)
        None
      end
    | let x: NativeFunction => 
      x
    end

  fun print(exp: MalType): String => 
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
