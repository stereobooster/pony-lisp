// TODO: http://www.lispworks.com/documentation/HyperSpec/Body/03_ababa.htm
interface SpecialForm
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ?

interface Evaluator
  fun eval(ast: MalType, mal_env: MalEnv): MalType ?

class IfFunction is SpecialForm
  let _e: Evaluator
  let _r: ErrorRegister
  new create(e: Evaluator, r: ErrorRegister) => _e = e; _r = r
  fun name(): String => "if"
  fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ? =>
    Decoder(_r).guard_array_length(2, 3, input)?
    let condition = Decoder(_r).as_bool(_e.eval(input(0)?, mal_env)?)?
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
    _e.eval(condition_expression, mal_env)?

class FnStarFunction is SpecialForm
  let _e: Evaluator
  let _r: ErrorRegister
  new create(e: Evaluator, r: ErrorRegister) => _e = e; _r = r
  fun name(): String => "fn*"
  fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let arguments  = Decoder(_r).as_array_symbol(input(0)?)?
    // Decoder(_r).guard_array_unique(arguments)?
    MalLambda(arguments, input(1)?, mal_env)

class DoFunction is SpecialForm
  let _e: Evaluator
  let _r: ErrorRegister
  new create(e: Evaluator, r: ErrorRegister) => _e = e; _r = r
  fun name(): String => "do"
  fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ? =>
    for v in input.values() do
      _e.eval(v, mal_env)?
    end

class DefExclamationFunction is SpecialForm
  let _e: Evaluator
  let _r: ErrorRegister
  new create(e: Evaluator, r: ErrorRegister) => _e = e; _r = r
  fun name(): String => "def!"
  fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let name' = Decoder(_r).as_symbol(input(0)?)?
    let output = _e.eval(input(1)?, mal_env)?
    mal_env.set(name' .value, output)
    output

// class LetStarFunction is SpecialForm
//   let _e: Evaluator
//   let _r: ErrorRegister
//   new create(e: Evaluator, r: ErrorRegister) => _e = e; _r = r
//   fun name(): String => "let*"
//   fun ref apply(input: Array[MalType], mal_env: MalEnv): MalType ? =>
//     Decoder(_r).guard_array_length(2, 2, input)?
//     let variables = Decoder(_r).as_array(input(0)?)?
//     // Decoder(_r).guard_array_length_even(variables)?
//     // Decoder(_r).guard_let_clause(variables)?
//     let new_lisp_env = MalEnv(mal_env)
//     // for (k, v) in y.value.pairs() do
//     //   eval_def_bang(v, y.value(k + 1)?, new_lisp_env)?
//     // end
//     let new_lisp_env = MalEnv(mal_env)
//     eval(input(1)?, new_lisp_env)

