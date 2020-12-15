use "collections"
use "debug"

// Object that provides handlers for I/O, Error
class EffectHandler
  var _error: (String | None) = None
  let _out: OutStream
  new create(out: OutStream) =>
    _out = out
  // TODO: TypeError, RuntimeError, SyntaxError
  fun err(e: (String | None)) =>
    // temp solution
    _out.print(e.string())
    // _error = consume e
  fun print(str: String) => _out.print(str)

class Mal
  let _env: MalEnv
  let _eh: EffectHandler

  // TODO: on_read, on_print, on_error
  new create(effect_handler: EffectHandler) =>
    _eh = effect_handler
    // can't move this and _eh out of constructor because of refcap
    _env = MalEnv()
    // add special forms
    _env.set("if", IfFunction(this, _eh))
    _env.set("fn*", FnStarFunction(this, _eh))
    _env.set("do", DoFunction(this, _eh))
    _env.set("def!", DefExclamationFunction(this, _eh))
    _env.set("let*", LetStarFunction(this, _eh))
    // add native functions
    _env.set("+", PlusFunction(_eh))
    _env.set("-", MinusFunction(_eh))
    _env.set("*", MultiplyFunction(_eh))
    _env.set("/", DivideFunction(_eh))
    _env.set("list", ListFunction(_eh))
    _env.set("list?", ListQuestionFunction(_eh))
    _env.set("empty?", EmptyQuestionFunction(_eh))
    _env.set("count", CountFunction(_eh))
    _env.set("=", EqualFunction(_eh))
    _env.set("<", LessFunction(_eh))
    _env.set("<=", LessOrEqualFunction(_eh))
    _env.set(">", MoreFunction(_eh))
    _env.set(">=", MoreOrEqualFunction(_eh))
    _env.set("pr-str", PrStrFunction(_eh))
    _env.set("str", StrFunction(_eh))
    _env.set("prn", PrnFunction(_eh))
    _env.set("println", PrintlnFunction(_eh))
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
      _eh.err("Read error")
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
      _eh.err("Error: expected function")
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
        _eh.err("Error: Variable not found " + input'.value)
        error
      end
    end

  fun print(exp: MalType): String =>
    Printer.print_str(exp)

  fun ref rep (str: String): String ? =>
    print(eval(read(str), _env)?)