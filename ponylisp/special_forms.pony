// TODO: http://www.lispworks.com/documentation/HyperSpec/Body/03_ababa.htm
interface SpecialForm
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ?

interface Evaluator
  fun eval(ast: MalType, env: MalEnv): MalType ?

class IfFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, r: EffectHandler) => _e = e; _eh = r
  fun name(): String => "if"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 3, input)?
    let condition = Decoder(_eh).as_bool(_e.eval(input(0)?, env)?)?
    // TODO: customise error message "Error: condition must be bool"
    let condition_expression = if condition then
      input(1)?
    else
      try
        input(2)? // else is optional
      else
        return None
      end
    end
    _e.eval(condition_expression, env)?

class FnStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, r: EffectHandler) => _e = e; _eh = r
  fun name(): String => "fn*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments  = Decoder(_eh).as_array_symbol(input(0)?)?
    // Decoder(_eh).guard_array_unique(arguments)?
    MalLambda(arguments, input(1)?, env)

class DoFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, r: EffectHandler) => _e = e; _eh = r
  fun name(): String => "do"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    for v in input.values() do
      _e.eval(v, env)?
    end

class DefExclamationFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, r: EffectHandler) => _e = e; _eh = r
  fun name(): String => "def!"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let name' = Decoder(_eh).as_symbol(input(0)?)?
    let output = _e.eval(input(1)?, env)?
    env.set(name' .value, output)
    output

class LetStarFunction is SpecialForm
  let _e: Evaluator
  let _eh: EffectHandler
  new create(e: Evaluator, r: EffectHandler) => _e = e; _eh = r
  fun name(): String => "let*"
  fun ref apply(input: Array[MalType], env: MalEnv): MalType ? =>
    let variables = Decoder(_eh).as_let_pairs(input(0)?)?
    let new_lisp_env = MalEnv(env)
    for v in variables.values() do
      env.set(v._1.value, _e.eval(v._2, new_lisp_env)?)
    end
    _e.eval(input(1)?, new_lisp_env)?
