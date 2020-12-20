use "collections"

class Decoder
  let _eh: ErrorHandler

  // TODO: Assertion error (expected, got)
  new create(effect_handler: ErrorHandler) =>
    _eh = effect_handler

  fun ref as_symbol(input: MalType): MalSymbol ? =>
    match input
    | let output: MalSymbol => output
    else
      _eh.err("Expected symbol instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_bool(input: MalType): Bool ? =>
    match input
    | let output: Bool => output
    else
      _eh.err("Expected bool instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_list(input: MalType): MalList ? =>
    match input
    | let output: MalList => output
    // to make `cons` work, maybe not a good idea
    | let output: None => MalList([])
    | let output: MalVector => MalList(output.value)
    else
      _eh.err("Expected list instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_integer(input: MalType): I64 ? =>
    match input
    | let output: I64 => output
    // | let output: F64 => output
    else
      _eh.err("Expected integer instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_string(input: MalType): String ? =>
    match input
    | let output: String => output
    else
      _eh.err("Expected string instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_atom(input: MalType): MalAtom ? =>
    match input
    | let output: MalAtom => output
    else
      _eh.err("Expected atom instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_lambda(input: MalType): MalLambda ? =>
    match input
    | let output: MalLambda => output
    else
      _eh.err("Expected function instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_array_symbol(input: (MalType | Array[MalType])): Array[MalSymbol] ? =>
    match input
    | let output: MalList => as_array_symbol(output.value)?
    | let output: MalVector => as_array_symbol(output.value)?
    | let output: Array[MalType] =>
      let output' = Array[MalSymbol]
      for (k, v) in output.pairs() do
        match v
        | let v': MalSymbol => output'.push(v')
        else
          _eh.err("Expected list of symbols instead got " + MalTypeUtils.type_of(v) + " at " + k.string())
          error
        end
      end
      output'
    else
      // _eh.err("Expected list instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_array_i64(input: (MalType | Array[MalType])): Array[I64] ? =>
    match input
    | let output: MalList => as_array_i64(output.value)?
    | let output: MalVector => as_array_i64(output.value)?
    | let output: Array[MalType] =>
      let output' = Array[I64]
      for (k, v) in output.pairs() do
        match v
        | let v': I64 => output'.push(v')
        else
          _eh.err("Expected list of integers instead got " + MalTypeUtils.type_of(v) + " at " + k.string())
          error
        end
      end
      output'
    else
      _eh.err("Expected list")// instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref as_array_list(input: (MalType | Array[MalType])): Array[MalList] ? =>
    match input
    | let output: MalList => as_array_list(output.value)?
    | let output: MalVector => as_array_list(output.value)?
    | let output: Array[MalType] =>
      let output' = Array[MalList]
      for (k, v) in output.pairs() do
        match v
        | let v': MalList => output'.push(v')
        // to make `concat` work, maybe not a good idea
        | let v': None => output'.push(MalList([]))
        | let v': MalVector => output'.push(MalList(v'.value))
        else
          _eh.err("Expected list of lists instead got " + MalTypeUtils.type_of(v) + " at " + k.string())
          error
        end
      end
      output'
    else
      _eh.err("Expected list")// instead got " + MalTypeUtils.type_of(input))
      error
    end

  fun ref guard_array_length(min: USize, max: USize, input: Array[MalType]) ? =>
    if (input.size() < min) or (input.size() > max) then
      _eh.err("Expected array of lenght " + min.string() + "-" + max.string()
       + " instead got " + input.size().string())
      error
    end

  fun ref as_let_pairs(input: (MalType | Array[MalType])): Array[(MalSymbol, MalType)] ? =>
    match input
    | let output: MalList => as_let_pairs(output.value)?
    | let output: MalVector => as_let_pairs(output.value)?
    | let output: Array[MalType] =>
      if (output.size() %% 2) != 0 then
        _eh.err("Expected list of even length")
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
            _eh.err("Repeated value " + v'.value)
            error
          end
        else
          _eh.err("Expected list of symbols and values instead got " + MalTypeUtils.type_of(output(i)?) + " at " + i.string())
          error
        end
        i = i + 2
      end
      output'
    else
      _eh.err("Expected list")// instead got " + MalTypeUtils.type_of(input))
      error
    end

  // it does nothing, it is here to make compiler happy
  fun ref empty_guard() ? =>
    if false then error end
