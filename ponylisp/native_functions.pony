use "itertools"

// TODO: TypeError, RUntimeError, SyntaxError
// TODO: map function https://stdlib.ponylang.org/src/itertools/iter/#L463
class NFError
  let _value: String
  new create(value: String) => _value = consume value
  fun ref apply(): String => _value

class NFSuccess[R]
  let _value: R
  new create(value: R) => _value = consume value
  fun ref apply(): R => _value

type NFResult[R] is (NFError | NFSuccess[R])

primitive DecodeArray
  fun i64(input: Array[MalType]): NFResult[Array[I64]] =>
    // why this doesn't work? 
    // NFSuccess[Array[I64]](input as Array[I64])
    let output = Array[I64](input.size())
    for v in input.values() do
      match v
      | let t: I64 => output.push(t)
      else
        return NFError("Not an integer array")
      end
    end
    NFSuccess[Array[I64]](output)
  
  fun symbol(input: Array[MalType]): NFResult[Array[MalSymbol]] =>
    let output = Array[MalSymbol](input.size())
    for v in input.values() do
      match v
      | let t: MalSymbol => output.push(t)
      else
        return NFError("Not a symbol array")
      end
    end
    NFSuccess[Array[MalSymbol]](output)

interface NativeFunction
  // it can provide documentation or type signature
  fun name(): String
  fun apply(input: Array[MalType]): NFResult[MalType] 

interface NativePartialFunction
  fun name(): String
  fun apply(input: Array[MalType]): NFResult[MalType] ?

class PlusFunction is NativeFunction
  fun name(): String => "+"
  fun apply(input: Array[MalType]): NFResult[MalType] =>
    if input.size() < 2 then
      return NFError("Requires at least two arguments")
    end
    let arguments = match DecodeArray.i64(input)
      | let e: NFError => return e
      | let a: NFSuccess[Array[I64]] => a()
    end
    let output = Iter[I64](arguments.values())
      .fold[I64](0, {(acc, x) => acc + x })
    NFSuccess[MalType](consume output)

class MinusFunction is NativeFunction
  fun name(): String => "-"
  fun apply(input: Array[MalType]): NFResult[MalType] =>
    if input.size() != 2 then
      return NFError("Requires two arguments")
    end
    let arguments = match DecodeArray.i64(input)
      | let e: NFError => return e
      | let a: NFSuccess[Array[I64]] => a()
    end
    try
      let output = arguments(0)? - arguments(1)?
      NFSuccess[MalType](consume output)
    else
      return NFError("Can't happen")
    end
    
class MultiplyFunction is NativeFunction
  fun name(): String => "*"
  fun apply(input: Array[MalType]): NFResult[MalType] =>
    if input.size() < 2 then
      return NFError("Requires at least two arguments")
    end
    let arguments = match DecodeArray.i64(input)
      | let e: NFError => return e
      | let a: NFSuccess[Array[I64]] => a()
    end
    let output = Iter[I64](arguments.values())
      .fold[I64](1, {(acc, x) => acc * x })
    NFSuccess[MalType](consume output)

class DivideFunction is NativeFunction
  fun name(): String => "/"
  fun apply(input: Array[MalType]): NFResult[MalType] =>
    if input.size() != 2 then
      return NFError("Requires two arguments")
    end
    let arguments = match DecodeArray.i64(input)
      | let e: NFError => return e
      | let a: NFSuccess[Array[I64]] => a()
    end
    try
      let output = arguments(0)? / arguments(1)?
      NFSuccess[MalType](consume output)
    else
      return NFError("Can't divide")
    end
