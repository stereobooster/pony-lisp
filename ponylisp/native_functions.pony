use "itertools"

interface NativeFunction
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType]): MalType ?

class PlusFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "+"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let arguments = Decoder(_r).as_array_i64(input)?
    Iter[I64](arguments.values())
      .fold[I64](0, {(acc, x) => acc + x })
    
class MinusFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "-"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let arguments = Decoder(_r).as_array_i64(input)?
    arguments(0)? - arguments(1)?
    
class MultiplyFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "*"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let arguments = Decoder(_r).as_array_i64(input)?
    Iter[I64](arguments.values())
      .fold[I64](1, {(acc, x) => acc * x })

class DivideFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "/"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let arguments = Decoder(_r).as_array_i64(input)?
    arguments(0)? / arguments(1)?
