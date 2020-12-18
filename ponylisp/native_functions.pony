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

class ReadStringFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "read-string"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let first = Decoder(_eh).as_string(input(0)?)?
    try
      let reader = Reader.create()?
      reader.read_str(first)?
    else
      _eh.err("Parse error")
    end

class SlurpFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "slurp"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let first = Decoder(_eh).as_string(input(0)?)?
    try
      _eh.read_file(first)?
    else
      _eh.err("Can't read file '" + first + "'")
    end

class AtomFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "atom"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    MalAtom(input(0)?)

class AtomQuestionFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "atom?"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalAtom => true
    else false end

class DerefFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "deref"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    let first = Decoder(_eh).as_atom(input(0)?)?
    first.value

class ResetExclamationFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "reset!"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = Decoder(_eh).as_atom(input(0)?)?
    let second = input(1)?
    first.value = second
    second

class ConsFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "cons"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let first = input(0)?
    var second = Decoder(_eh).as_list(input(1)?)?.value.clone()
    second.unshift(first)
    MalList(second)

class ConcatFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "concat"
  fun ref apply(input: Array[MalType]): MalType ? =>
    let list: Array[MalList] = Decoder(_eh).as_array_list(input)?
    let output: Array[MalType] = []
    for v in list.values() do
      output.concat(v.value.values())
    end
    MalList(output)

class VecFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "concat"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalList => MalVector(output.value)
    | let output: MalVector => output
    // | let output: None => MalVector([])
    else
      _eh.err("Expected list or vector instead got " + MalTypeUtils.type_of(input(0)?))
      error
    end

class NthFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "nth"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(2, 2, input)?
    let index = USize.from[I64](Decoder(_eh).as_integer(input(1)?)?)
    match input(0)?
    | let output: MalList =>
      try
        output.value(index)?
      else
        _eh.err("Out of range " + index.string())
        error
      end
    | let output: MalVector =>
      try
        output.value(index)?
      else
        _eh.err("Out of range " + index.string())
        error
      end
    // | let output: None => MalVector([])
    else
      _eh.err("Expected list or vector instead got " + MalTypeUtils.type_of(input(0)?))
      error
    end

class FirstFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "first"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalList =>
      try
        output.value(0)?
      else
        None
      end
    | let output: MalVector =>
      try
        output.value(0)?
      else
        None
      end
    | let output: None => None
    else
      _eh.err("Expected list or vector instead got " + MalTypeUtils.type_of(input(0)?))
      error
    end

class RestFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "rest"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(1, 1, input)?
    match input(0)?
    | let output: MalList =>
      MalList(output.value.slice(1))
    | let output: MalVector =>
      MalList(output.value.slice(1))
    | let output: None => MalList([])
    else
      _eh.err("Expected list or vector instead got " + MalTypeUtils.type_of(input(0)?))
      error
    end

class ThrowFunction is NativeFunction
  let _eh: EffectHandler
  new create(r: EffectHandler) => _eh = r
  fun name(): String => "throw"
  fun ref apply(input: Array[MalType]): MalType ? =>
    Decoder(_eh).guard_array_length(0, 1, input)?
    let first = try input(0)? end
    match first
    | None => _eh.err(None)
    | let first': String =>
      _eh.err(first')
    else
      _eh.err(Printer.print_str(first))
    end
    error
