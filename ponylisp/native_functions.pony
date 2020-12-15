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

class ListFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "list"
  fun ref apply(input: Array[MalType]): MalType ? =>
    (Decoder(_r).empty_guard()?)
    MalList(input)

class ListQuestionFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "list?"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalList => true
    else false end

class EmptyQuestionFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "empty?"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(1, 1, input)?
    let output = Decoder(_r).as_list(input(0)?)?
    output.value.size() == 0

class CountFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "count"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(1, 1, input)?
    let output = Decoder(_r).as_list(input(0)?)?
    I64.from[USize](output.value.size())

class EqualFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    match MalTypeUtils.eq(input(0)?, input(1)?)
    | let output: Bool => output
    | None => false
    end

// TODO: support strings, floats
class LessFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "<"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let first = Decoder(_r).as_integer(input(0)?)?
    let second = Decoder(_r).as_integer(input(1)?)?
    first < second

class LessOrEqualFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => "<="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let first = Decoder(_r).as_integer(input(0)?)?
    let second = Decoder(_r).as_integer(input(1)?)?
    first <= second

class MoreFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => ">"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let first = Decoder(_r).as_integer(input(0)?)?
    let second = Decoder(_r).as_integer(input(1)?)?
    first > second

class MoreOrEqualFunction is NativeFunction
  let _r: ErrorRegister
  new create(r: ErrorRegister) => _r = r
  fun name(): String => ">="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_r).guard_array_length(2, 2, input)?
    let first = Decoder(_r).as_integer(input(0)?)?
    let second = Decoder(_r).as_integer(input(1)?)?
    first >= second
