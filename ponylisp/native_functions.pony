use "itertools"

interface NativeFunction
  // it can provide documentation or type signature
  fun name(): String
  fun ref apply(input: Array[MalType]): MalType ?

class PlusFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "+"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments = Decoder(_eh).as_array_i64(input)?
    Iter[I64](arguments.values())
      .fold[I64](0, {(acc, x) => acc + x })

class MinusFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "-"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments = Decoder(_eh).as_array_i64(input)?
    arguments(0)? - arguments(1)?

class MultiplyFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "*"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments = Decoder(_eh).as_array_i64(input)?
    Iter[I64](arguments.values())
      .fold[I64](1, {(acc, x) => acc * x })

class DivideFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "/"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let arguments = Decoder(_eh).as_array_i64(input)?
    arguments(0)? / arguments(1)?

class ListFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "list"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).empty_guard()?
    MalList(input)

class ListQuestionFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "list?"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalList => true
    else false end

class EmptyQuestionFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "empty?"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let output = Decoder(_eh).as_list(input(0)?)?
    output.value.size() == 0

class CountFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "count"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let output = Decoder(_eh).as_list(input(0)?)?
    I64.from[USize](output.value.size())

class EqualFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    match MalTypeUtils.eq(input(0)?, input(1)?)
    | let output: Bool => output
    | None => false
    end

// TODO: support strings, floats
class LessFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "<"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = Decoder(_eh).as_integer(input(0)?)?
    let second = Decoder(_eh).as_integer(input(1)?)?
    first < second

class LessOrEqualFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "<="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = Decoder(_eh).as_integer(input(0)?)?
    let second = Decoder(_eh).as_integer(input(1)?)?
    first <= second

class MoreFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => ">"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = Decoder(_eh).as_integer(input(0)?)?
    let second = Decoder(_eh).as_integer(input(1)?)?
    first > second

class MoreOrEqualFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => ">="
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = Decoder(_eh).as_integer(input(0)?)?
    let second = Decoder(_eh).as_integer(input(1)?)?
    first >= second

class PrStrFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "pr-str"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).empty_guard()?
    Iter[MalType](input.values())
      .fold[String]("",
        {(buf, x) => buf + Printer.print_str(x, true) + " " })

class StrFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "str"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).empty_guard()?
    Iter[MalType](input.values())
      .fold[String]("",
        {(buf, x) => buf + Printer.print_str(x, false) })

class PrnFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "prn"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).empty_guard()?
    let str = Iter[MalType](input.values())
      .fold[String]("",
        {(buf, x) => buf + Printer.print_str(x, true) + " " })
    _eh.print(str)
    None

class PrintlnFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "println"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).empty_guard()?
    let str = Iter[MalType](input.values())
      .fold[String]("",
        {(buf, x) => buf + Printer.print_str(x, false) + " " })
    _eh.print(str)
    None
