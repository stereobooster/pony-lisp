// TODO: http://www.lispworks.com/documentation/HyperSpec/Body/03_ababa.htm
interface SpecialForm
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ?

interface Evaluator
  fun eval(input: MalType, env: MalEnv): MalType ?

class DefExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "def!"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let name' = Decoder(_eh).as_symbol(input(0)?)?
    let output = _e.eval(input(1)?, env)?
    env.set(name' .value, output)
    output

class FnStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "fn*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments  = Decoder(_eh).as_array_symbol(input(0)?)?
    // Decoder(_eh).guard_array_unique(arguments)?
    MalLambda(arguments, input(1)?, env)

class IfFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "if"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 3, input)?
    // TODO: customise error message "Error: condition must be bool"
    let condition = Decoder(_eh).as_bool(_e.eval(input(0)?, env)?)?
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
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
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
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "let*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    let variables = Decoder(_eh).as_let_pairs(input(0)?)?
    let new_env = MalEnv(env)
    for v in variables.values() do
      new_env.set(v._1.value, _e.eval(v._2, env)?)
    end
    let last: MalType = input(1)?
    _e.eval(last, new_env)?

class EvalFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "eval"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    _e.eval(_e.eval(input(0)?, env)?, env.root())?

class QuoteFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
  fun name(): String => "quote"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    input(0)?

// TODO: write it in lisp instead
class SwapExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
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

// this makes compilation slower

// interface SpecialFormTCO
//   fun name(): String
//   fun ref apply_tco(input: Array[MalType], env: MalEnv): (MalType, MalEnv) ?

// class IfFunction is SpecialFormTCO
//   let _e: Evaluator
//   let _eh: EffectHandler
//   new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
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

// class DoFunction is SpecialFormTCO
//   let _e: Evaluator
//   let _eh: EffectHandler
//   new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
//   fun name(): String => "do"

//   fun ref apply_tco(input: Array[MalType], env: MalEnv): (MalType, MalEnv) ? =>
//     Decoder(_eh).guard_array_length(1, USize.max_value(), input)?
//     let last: MalType = input.pop()?
//     for v in input.values() do
//       _e.eval(v, env)?
//     end
//     (last, env)

//   fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
//     let result = apply_tco(input, env)?
//     let input': MalType = result._1
//     let env': MalEnv = result._2
//     _e.eval(input', env')?

// class LetStarFunction is SpecialFormTCO
//   let _e: Evaluator
//   let _eh: EffectHandler
//   new create(e: Evaluator, eh: EffectHandler) => _e = e; _eh = eh
//   fun name(): String => "let*"

//   fun ref apply_tco(input: Array[MalType], env: MalEnv): (MalType, MalEnv) ? =>
//     let variables = Decoder(_eh).as_let_pairs(input(0)?)?
//     let new_env = MalEnv(env)
//     for v in variables.values() do
//       env.set(v._1.value, _e.eval(v._2, new_env)?)
//     end
//     let last: MalType = input(1)?
//     (last, new_env)

//   fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
//     let result = apply_tco(input, env)?
//     let input': MalType = result._1
//     let env': MalEnv = result._2
//     _e.eval(input', env')?
