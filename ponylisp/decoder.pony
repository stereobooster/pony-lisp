use "collections"

class Decoder
  let _register: ErrorRegister

  // TODO: Assertion error (expected, got)
  new create(register: ErrorRegister) =>
    _register = register

  fun ref as_symbol(input: MalType): MalSymbol ? =>
    match input
    | let output: MalSymbol => output
    else
      _register.set("Expected symbol") // instead got typoef(input)
      error
    end

  fun ref as_bool(input: MalType): Bool ? =>
    match input
    | let output: Bool => output
    else
      _register.set("Expected bool") // instead got typoef(input)
      error
    end

  fun ref as_list(input: MalType): MalList ? =>
    match input
    | let output: MalList => output
    else
      _register.set("Expected list") // instead got typoef(input)
      error
    end

  fun ref as_integer(input: MalType): I64 ? =>
    match input
    | let output: I64 => output
    // | let output: F64 => output
    else
      _register.set("Expected integer") // instead got typoef(input)
      error
    end

  fun ref as_array_symbol(input: (MalType | Array[MalType])): Array[MalSymbol] ? =>
    match input
    | let output: MalList => as_array_symbol(output.value)?
    | let output: MalVector => as_array_symbol(output.value)?
    | let output: Array[MalType] =>
      let output' = Array[MalSymbol]
      for v in output.values() do
        match v
        | let v': MalSymbol => output'.push(v')
        else
          _register.set("Expected list of symbols") // instead got typoef(input) at position i
          error
        end
      end
      output'
    else
      _register.set("Expected list of symbols") // instead got typoef(input)
      error
    end

  fun ref as_array_i64(input: (MalType | Array[MalType])): Array[I64] ? =>
    match input
    | let output: MalList => as_array_i64(output.value)?
    | let output: MalVector => as_array_i64(output.value)?
    | let output: Array[MalType] =>
      let output' = Array[I64]
      for v in output.values() do
        match v
        | let v': I64 => output'.push(v')
        else
          _register.set("Expected list of integers") // instead got typoef(input) at position i
          error
        end
      end
      output'
    else
      _register.set("Expected list of integers") // instead got typoef(input)
      error
    end

  fun ref guard_array_length(min: USize, max: USize, input: Array[MalType]) ? =>
    if (input.size() < min) or (input.size() > max) then
      _register.set("Expected array of lenght " + min.string() + "-" + max.string()
        + " instead got " + input.size().string())
      error
    end

  fun ref as_let_pairs(input: (MalType | Array[MalType])): Array[(MalSymbol, MalType)] ? =>
    match input
    | let output: MalList => as_let_pairs(output.value)?
    | let output: MalVector => as_let_pairs(output.value)?
    | let output: Array[MalType] =>
      if (output.size() %% 2) != 0 then
        _register.set("Expected list of even length")
        error
      end
      let existing_keys = Set[String]
      let output' = Array[(MalSymbol, MalType)]
      var i: USize = 0
      while i < output.size() do
        match output(i)?
        | let v': MalSymbol =>
          if not existing_keys.contains(v'.value) then
            output'.push((v', output(i + 1)?))
            existing_keys.set(v'.value)
          else
            _register.set("Repeated value " + v'.value)
            error
          end
        else
          _register.set("Expected symbol") // instead got typoef(input) at position i
          error
        end
        i = i + 2
      end
      output'
    else
      _register.set("Expected list of symbols") // instead got typoef(input)
      error
    end

  // it does nothing, it is here to make compiler happy
  fun ref empty_guard() ? =>
    if false then error end
