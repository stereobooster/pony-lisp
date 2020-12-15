use "collections"
use "debug"

// ErrorHandler?
// TODO: TypeError, RUntimeError, SyntaxError
class ErrorRegister
  var _error: (String | None) = None
  let _out: OutStream
  new create(out: OutStream) =>
    _out = out
  // fun ref get(): (String | None) => _error = None
  fun set(e: (String | None)) =>
    // temp solution
    _out.print(e.string())
    // _error = consume e

// class DefaultMalEnv
//   fun calc(): MalEnv =>
//     let env = MalEnv()
//     env.set("+", PlusFunction)
//     env.set("-", MinusFunction)
//     env.set("*", MultiplyFunction)
//     env.set("/", DivideFunction)
//     env

class Mal
  let _env: MalEnv
  let _register: ErrorRegister

  // TODO: on_read, on_print, on_error
  new create(register': ErrorRegister) =>
    _register = register'
    // can't move this and _register out of constructor because of refcap
    _env = MalEnv()
    // add special forms
    _env.set("if", IfFunction(this, _register))
    _env.set("fn*", FnStarFunction(this, _register))
    _env.set("do", DoFunction(this, _register))
    _env.set("def!", DefExclamationFunction(this, _register))
    _env.set("let*", LetStarFunction(this, _register))
    // add native functions
    _env.set("+", PlusFunction(_register))
    _env.set("-", MinusFunction(_register))
    _env.set("*", MultiplyFunction(_register))
    _env.set("/", DivideFunction(_register))
    _env.set("list", ListFunction(_register))
    _env.set("list?", ListQuestionFunction(_register))
    _env.set("empty?", EmptyQuestionFunction(_register))
    _env.set("count", CountFunction(_register))
    _env.set("=", EqualFunction(_register))
    _env.set("<", LessFunction(_register))
    _env.set("<=", LessOrEqualFunction(_register))
    _env.set(">", MoreFunction(_register))
    _env.set(">=", MoreOrEqualFunction(_register))
    try
      // add lambdas
      rep("(def! not (fn* (a) (if a false true)))")?
    end

  fun debug_val(value: MalType) =>
    match value
    | None => Debug(None)
    | let x: Bool => Debug(x)
    | let x: I64 => Debug(x)
    | let x: F64 => Debug(x)
    | let x: String => Debug("String"); Debug(x)
    | let x: MalList => Debug("MalList")
    | let x: MalVector => Debug("MalVector")
    | let x: MalMap => Debug("MalMap")
    | let x: MalSymbol => Debug("MalSymbol"); Debug(x.value)
    | let x: MalKeyword => Debug("MalKeyword"); Debug(x.value)
    | let x: NativeFunction => Debug("NativeFunction"); Debug(x.name())
    | let x: SpecialForm => Debug("SpecialForm"); Debug(x.name())
    | let x: MalLambda => Debug("MalLambda")
    end

  fun read(str: String): MalType =>
    try
      let reader = Reader.create()?
      reader.read_str(str)?
    else
      _register.set("Read error")
    end

  fun eval_application(list: MalList, env: MalEnv): MalType ? =>
    let input = list.value
    if input.size() == 0 then
      return None
    end
    match eval(input(0)?, env)?
    | let fn: SpecialForm =>
      fn.apply(input.slice(1), env)?
    | let fn: NativeFunction =>
      let evaluated_input: Array[MalType] = []
      for v in input.slice(1).values() do
        evaluated_input.push(eval(v, env)?)
      end
      fn.apply(evaluated_input)?
    | let fn: MalLambda =>
        let new_lisp_env = MalEnv(fn.env)
        for (k, v) in fn.arguments.pairs() do
          env.set(v.value, eval(input(k + 1)?, new_lisp_env)?)
        end
        eval(fn.body, new_lisp_env)?
    else
      _register.set("Error: expected function")
      error
    end

  fun eval(input: MalType, env: MalEnv): MalType ? =>
    match input
    | None => None
    | let input': Bool => input'
    | let input': I64 => input'
    | let input': F64 => input'
    | let input': String => input'
    | let input': MalKeyword => input'
    | let input': NativeFunction => input'
    | let input': SpecialForm => input'
    | let input': MalVector =>
      let output: Array[MalType] = []
      for v in input'.value.values() do
        output.push(eval(v, env)?)
      end
      MalVector(output)
    | let input': MalMap =>
      let output = Map[String, MalType](input'.value.size())
      for (k, v) in input'.value.pairs() do
        output(k) = eval(v, env)?
      end
      MalMap(output)
    | let input': MalList => eval_application(input', env)?
    | let input': MalSymbol =>
      try
        env.get(input'.value)?
      else
        _register.set("Error: Variable not found " + input'.value)
        error
      end
    end

  fun print(exp: MalType): String =>
    Printer.print_str(exp)

  fun ref rep (str: String): String ? =>
    print(eval(read(str), _env)?)