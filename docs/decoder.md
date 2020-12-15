# Decoder

I use union to represent Lisp types:

```pony
type MalAtom is (I64 | F64 | String | None | Bool | MalSymbol | MalKeyword)
```

Whenever I need to use actual parameter, I need to do "type assserion" with match:

```pony
fun eval_def_bang(name: MalType, value: MalType, mal_env: MalEnv): MalType ? => 
  match name
    | let name': MalSymbol => 
      let value_evaluated = eval(value, mal_env)
      mal_env.set(name'.value, value_evaluated)
  else
    out.print("Error: Expects list as the second argument")
    error
  end
```

which leads to a lot of repetitive code (looks noisy).

One way to solve is some kind of type assertion (there is built-in `as` operator, but it doesn't work for all values):

```pony
fun as_symbol(input: MalType): MalSymbol ? =>
  match input
  | let input': MalSymbol => input'
  else
    error
  end

fun eval_def_bang(name: MalType, value: MalType, mal_env: MalEnv): MalType ? => 
  let name' = as_symbol(name)?
  let value_evaluated = eval(value, mal_env)
  mal_env.set(name'.value, value_evaluated)
```

This code is denser, but the question is how to pass error messages. I have two options:

1. "Either monad" + pipe function + zip? function (pseudo code)

```pony
// input is MalType
let output = Pipe[MalType](Decoder~symbol_array())
  .chain(Decoder~array_length(2, 3))
  .chain(Decoder~array_unique())
  (input)

match output
  | let e: NFError => 
    // print error
  | let a: NFSuccess[Array[MalSymbol]] => 
    // do something
  end
```

I still neeed to use `match`, but less than before.

2. Store error in the validation object (this is kind of global variable)

```pony
let output = _decoder.symbol_array(input)?
_decoder.array_length(2, 3, input)?
_decoder.array_unique(input)?

_decoder.error_message()
```

Do I pass it to every function/object that needs to use it? When to do clean up of message? Do I need to accumulate more than message?
