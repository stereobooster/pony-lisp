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
