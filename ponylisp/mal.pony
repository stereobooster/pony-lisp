use "collections"
use "files"
// use "debug"

// Object that provides handlers for I/O, Error
class EffectHandler
  // var _error: (String | None) = None
  let _out: OutStream
  let _root: (AmbientAuth | None)
  new create(out: OutStream, root: (AmbientAuth | None)) =>
    _out = out
    _root = root
  // TODO: TypeError, RuntimeError, SyntaxError
  fun err(e: (String | None)) =>
    // temp solution
    _out.print(e.string())
    // _error = consume e
  fun print(str: String) =>
    _out.print(str)
  fun read_file(file_name: String): String ? =>
    let path = FilePath(_root as AmbientAuth, file_name)?
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

// can this be an actor?
class Mal
  let _env: MalEnv
  let _eh: EffectHandler

  new create(effect_handler: EffectHandler) =>
    _eh = effect_handler
    // can't move `this` and `_eh` out of constructor because of refcap
    _env = MalEnv()
    // add special forms
    _env.set("if", IfFunction(this, _eh))
    _env.set("fn*", FnStarFunction(this, _eh))
    _env.set("do", DoFunction(this, _eh))
    _env.set("def!", DefExclamationFunction(this, _eh))
    _env.set("let*", LetStarFunction(this, _eh))
    _env.set("eval", EvalFunction(this, _eh))
    _env.set("swap!", SwapExclamationFunction(this, _eh))
    _env.set("quote", QuoteFunction(this, _eh))
    _env.set("quasiquote", QuasiquoteFunction(this, _eh))
    _env.set("defmacro!", DefmacroExclamationFunction(this, _eh))
    _env.set("macroexpand", MacroexpandFunction(this, _eh))
    _env.set("try*", TryStarFunction(this, _eh))
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
    _env.set("read-string", ReadStringFunction(_eh))
    _env.set("slurp", SlurpFunction(_eh))
    _env.set("atom", AtomFunction(_eh))
    _env.set("atom?", AtomQuestionFunction(_eh))
    _env.set("deref", DerefFunction(_eh))
    _env.set("reset!", ResetExclamationFunction(_eh))
    _env.set("cons", ConsFunction(_eh))
    _env.set("concat", ConcatFunction(_eh))
    _env.set("vec", VecFunction(_eh))
    _env.set("nth", NthFunction(_eh))
    _env.set("first", FirstFunction(_eh))
    _env.set("rest", RestFunction(_eh))
    _env.set("throw", ThrowFunction(_eh))
    try
      // add lambdas
      rep("(def! not (fn* (a) (if a false true)))")?
      rep("""(def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) "\nnil)")))))""")?
      rep("""
      (defmacro! cond
        (fn* (& xs)
          (if (> (count xs) 0)
            (list 'if (first xs)
              (if (> (count xs) 1)
                (nth xs 1)
                (throw "odd number of forms to cond"))
              (cons 'cond (rest (rest xs)))))))
      """)?
      // TODO: need `&` support
      // rep("""(def! swap! (fn* (a, f, &rest) (reset! a (f (deref a) &rest)) ))""")?
    else
      _eh.print("Failed to create core functions")
    end

  fun _eval_data(input: MalType, env: MalEnv): MalType ? =>
    match input
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
    else
      input
    end

//  fun _indent(level': USize, indent: String = "  "): String iso =>
//     var level = level'
//     let buf = recover String(0) end
//     while level != 0 do
//       buf.append(indent)
//       level = level - 1
//     end
//     consume buf

  // https://opendsa.cs.vt.edu/ODSA/Books/PL/html/SLang2ParameterPassing.html#macro-expansion
  fun bind(fn: MalLambda, arguments: Array[MalType], env: MalEnv, is_macro: Bool = false): MalEnv ? =>
    let argument_names = fn.argument_names
    let is_rest_argument = (argument_names.size() >= 2) and
      (argument_names(argument_names.size() - 2)?.value == "&")
    if argument_names.size() != arguments.size() then
      let min_arguments = if is_rest_argument then argument_names.size() - 2 else argument_names.size() end
      let max_arguments = if is_rest_argument then USize.max_value() else argument_names.size() end
      if (arguments.size() < min_arguments) or (arguments.size() > max_arguments) then
        if min_arguments == max_arguments then
          _eh.err("Error: expected " + min_arguments.string() + " arguments, got " + arguments.size().string() + ")")
        else
          _eh.err("Error: expected at least " + min_arguments.string() + " arguments, got " + arguments.size().string() + ")")
        end
        error
      end
    end
    let new_env = MalEnv(fn.env)
    let rest_argument_value = Array[MalType]
    for (k, v) in arguments.pairs() do
      let argument_value = if is_macro then v else eval(v, env)? end
      if is_rest_argument and (k >= (argument_names.size() - 2)) then
        rest_argument_value.push(argument_value)
      else
        new_env.set(argument_names(k)?.value, argument_value)
      end
    end
    if is_rest_argument then
      new_env.set(argument_names(argument_names.size() - 1)?.value,
        MalList(rest_argument_value))
    end
    consume new_env

  fun macroexpand(fn: MalLambda, arguments: Array[MalType], env: MalEnv): MalType ? =>
    var fn' = fn
    var arguments' = arguments
    while true do
      let result = eval(fn'.body, bind(fn', arguments', env, true)?)?
      match result
      | let list: MalList =>
        if list.value.size() == 0 then
          return result
        end
        match list.value(0)?
        | let first: MalSymbol =>
          match try env.get(first.value)? end
          | let first': MalLambda =>
            if first'.is_macro then
              fn' = first'
              arguments' = list.value.slice(1)
              continue
            end
          end
        end
      end
      return result
    end


  fun eval(input: MalType, env: MalEnv): MalType ? =>
    var tco_input: MalType = consume input
    var tco_env: MalEnv = consume env
    // var counter: USize = 0
    while true do
      // _eh.print(_indent(tco_env.depth + counter) +
      //   Printer.print_str(tco_input))
      // counter = counter + 1
      // try
      //   _eh.print(Printer.print_str(tco_env.get("xs")?))
      // end
      match tco_input
      | let input': MalSymbol =>
        try
          return tco_env.get(input'.value)?
        else
          _eh.err("Error: Variable not found " + input'.value)
          error
        end
      | let input': MalList =>
        let list = input'.value
        if list.size() == 0 then
          // return None
          return MalList([])
        end
        let first = eval(list(0)?, tco_env)?
        let arguments = list.slice(1)
        match first
        | let fn: NativeFunction =>
          let evaluated_input: Array[MalType] = []
          for v in arguments.values() do
            evaluated_input.push(eval(v, tco_env)?)
          end
          return fn.apply(consume evaluated_input)?
        | let fn: SpecialForm =>
          return fn.apply(arguments, tco_env)?
        // | let fn: SpecialFormTCO =>
        //   let result: (MalType, MalEnv) = fn.apply_tco(arguments, tco_env)?
        //   tco_input = result._1
        //   tco_env = result._2
        //   continue
        | let fn: MalLambda =>
          if fn.is_macro then
            // tco_env = tco_env
            tco_input = macroexpand(fn, arguments, tco_env)?
          else
            tco_env = bind(fn, arguments, tco_env)?
            tco_input =fn.body
          end
          continue
        else
          match list(0)?
          | let s: MalPrimitive =>
            _eh.err("Error: " + Printer.print_str(s) + " is not a function (it is " + MalTypeUtils.type_of(first) + ")")
          else
            _eh.err("Error: first item in the list is not a function (it is " + MalTypeUtils.type_of(first) + ")")
          end
          error
        end
      else
        return _eval_data(tco_input, tco_env)?
      end
    end

  fun read(str: String): MalType =>
    try
      let reader = Reader.create()?
      reader.read_str(str)?
    else
      _eh.err("Read error")
    end

  fun print(exp: MalType): String =>
    Printer.print_str(exp, true)

  fun ref rep (str: String): String ? =>
    print(eval(read(str), _env)?)
