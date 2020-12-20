// TODO: http://www.lispworks.com/documentation/HyperSpec/Body/03_ababa.htm
interface SpecialForm
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ?

interface Evaluator
  fun eval(input: MalType, env: MalEnv): MalType ?
  // to support macroexpand, not sure this is a good idea
  fun macroexpand(fn: MalLambda, arguments: Array[MalType], env: MalEnv): MalType ?

class DefExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "def!"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let name' = Decoder(_eh).as_symbol(input(0)?)?
    let output = _e.eval(input(1)?, env)?
    env.set(name' .value, output)
    output

class FnStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "fn*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let argument_names  = Decoder(_eh).as_array_symbol(input(0)?)?
    // Decoder(_eh).guard_array_unique(argument_names)?
    // Decoder(_eh).guard_ampersand_before_last(argument_names)?
    MalLambda(argument_names, input(1)?, env)

class IfFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "if"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 3, input)?
    // TODO: customise error message "Error: condition must be bool"
    let condition = Decoder(_eh).as_bool(_e.eval(input(0)?, env)?)?
    // let condition = match _e.eval(input(0)?, env)?
    //   | None => false
    //   | let x: Bool => x
    // else
    //   true // ??
    // end
    let condition_expression: MalType = if condition then
      input(1)?
    else
      try
        input(2)? // else is optional
      else
        None
      end
    end
    _e.eval(condition_expression, env)?

class DoFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "do"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, USize.max_value(), input)?
    let last: MalType = input.pop()?
    for v in input.values() do
      _e.eval(v, env)?
    end
    _e.eval(last, env)?

class LetStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "let*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    let variables = Decoder(_eh).as_let_pairs(input(0)?)?
    let new_env = MalEnv(env)
    for v in variables.values() do
      new_env.set(v._1.value, _e.eval(v._2, new_env)?)
    end
    let last: MalType = input(1)?
    _e.eval(last, new_env)?

class EvalFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "eval"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    _e.eval(_e.eval(input(0)?, env)?, env.root())?

// TODO: write it in lisp instead
class SwapExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "swap!"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, USize.max_value(), input)?
    let evaluated_input: Array[MalType] = []
    for v in input.values() do
      evaluated_input.push(_e.eval(v, env)?)
    end
    let first = Decoder(_eh).as_atom(evaluated_input(0)?)?
    evaluated_input.update(0, evaluated_input(1)?)?
    evaluated_input.update(1, first.value)?
    first.value = _e.eval(MalList(evaluated_input), env)?
    first.value

class QuoteFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "quote"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    input(0)?

class QuasiquoteFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "quasiquote"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    _e.eval(expand(input(0)?, env)?, env)?

  // I regret I wrote this
  fun ref expand(input: MalType, env: MalEnv): MalType ? =>
    match input
    | let list: MalList =>
      if list.value.size() == 0 then
        return list
      end
      match list.value(0)?
      | let first: MalSymbol => if first.value == "unquote" then
          return list.value(1)?
        end
      end
      var result: MalList = MalList([])
      for v in list.value.reverse().values() do
        // _eh.print(Printer.print_str(result))
        match v
        | let v': MalList =>
          if v'.value.size() != 0 then
            match v'.value(0)?
            | let first': MalSymbol =>
              if first'.value == "splice-unquote" then
                result = MalList([
                  MalSymbol("concat")
                  v'.value(1)?
                  result
                ])
                continue
              end
            end
          end
        end
        result = MalList([
          MalSymbol("cons")
          expand(v, env)?
          result
        ])
      end
      return result
      | let list: MalVector =>
        if list.value.size() == 0 then
          return list
        end
        var result: MalList = MalList([])
        for v in list.value.reverse().values() do
          // _eh.print(Printer.print_str(result))
          match v
          | let v': MalList =>
            if v'.value.size() != 0 then
              match v'.value(0)?
              | let first': MalSymbol =>
                if first'.value == "splice-unquote" then
                  result = MalList([
                    MalSymbol("concat")
                    v'.value(1)?
                    result
                  ])
                  continue
                end
              end
            end
          end
          result = MalList([
            MalSymbol("cons")
            expand(v, env)?
            result
          ])
        end
        return MalList([
          MalSymbol("vec")
          result
        ])
    end
    MalList([MalSymbol("quote"); input])

class DefmacroExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "defmacro!"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let name' = Decoder(_eh).as_symbol(input(0)?)?
    let output = _e.eval(input(1)?, env)?
    let fn = Decoder(_eh).as_lambda(output)?
    // create new lambda to prevent mutation of original lambda in case it was passed as variable
    let fn' = MalLambda(fn.argument_names, fn.body, fn.env, true)
    env.set(name'.value, fn')
    fn'

class MacroexpandFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "macroexpand"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let list = Decoder(_eh).as_list(input(0)?)?
    let fn = Decoder(_eh).as_lambda(_e.eval(list.value(0)?, env)?)?
    if not fn.is_macro then
      _eh.err("Expect macro")
    end
    _e.macroexpand(fn, list.value.slice(1), env)?

class TryStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: ErrorHandler
  new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
  fun name(): String => "try*"
  fun _as_catch(input: MalType): ((MalSymbol, MalType) | None) ? =>
    try
      match input
      | let list: MalList =>
        if list.value.size() != 3 then
          error
        end
        match list.value(0)?
        | let symbol: MalSymbol =>
          if symbol.value != "catch*" then
            error
          end
        else
          error
        end
        match list.value(1)?
        | let symbol: MalSymbol =>
          return (symbol, list.value(2)?)
        else
          error
        end
      | None => return None
      else
        error
      end
    else
      _eh.err("Expected (catch* error handler), instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 2, input)?
    let catch = _as_catch(try input(1)? end)?
    try
      _e.eval(input(0)?, env)?
    else
      match catch
      | (let symbol: MalSymbol, let handler: MalType) =>
        let new_env = MalEnv(env)
        env.set(symbol.value, None)
        // env.set(symbol.value, _eh.last_error())
        _e.eval(handler, new_env)?
      end
    end

// this makes compilation slower

// interface SpecialFormTCO
//   fun name(): String
//   fun ref apply_tco(input: Array[MalType], env: MalEnv): (MalType, MalEnv) ?

// class IfFunction is SpecialFormTCO
//   let _e: Evaluator
//   let _eh: ErrorHandler
//   new create(e: Evaluator, eh: ErrorHandler) => _e = e; _eh = eh
//   fun name(): String => "if"

//   fun ref apply_tco(input: Array[MalType], env: MalEnv): (MalType, MalEnv) ? =>
//     Decoder(_eh).guard_array_length(2, 3, input)?
//     // TODO: customise error message "Error: condition must be bool"
//     let condition = Decoder(_eh).as_bool(_e.eval(input(0)?, env)?)?
//     let condition_expression: MalType = if condition then
//       input(1)?
//     else
//       try
//         input(2)? // else is optional
//       else
//         None
//       end
//     end
//     (condition_expression, env)

//   fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
//     let result = apply_tco(input, env)?
//     let input': MalType = result._1
//     let env': MalEnv = result._2
//     _e.eval(input', env')?
