use "collections"
use "format"

// https://github.com/ponylang/ponyc/blob/master/packages/json/_json_print.pony
primitive Printer
  fun _string_map(data: Map[String, MalType], buf': String iso, print_readably: Bool)
    : String iso^
  =>
    """
    Append the string representation of this object to the provided String.
    """
    var buf = consume buf'

    if data.size() == 0 then
      buf.append("{}")
      return buf
    end

    buf.push('{')

    var print_comma = false

    for (k, v) in data.pairs() do
      if print_comma then
        buf.push(' ')
      else
        print_comma = true
      end

      buf = _string(k, consume buf, print_readably)
      buf.push(' ')
      buf = _string(v, consume buf, print_readably)
    end

    buf.push('}')
    buf

  fun _string_array(
    data: Array[MalType],
    buf': String iso,
    print_readably: Bool,
    start: U8,
    finish: U8)
    : String iso^
  =>
    """
    Append the string representation of this array to the provided String.
    """
    var buf = consume buf'

    if data.size() == 0 then
      buf.push(start)
      buf.push(finish)
      return buf
    end

    buf.push(start)

    var print_comma = false

    for v in data.values() do
      if print_comma then
        buf.push(' ')
      else
        print_comma = true
      end

      buf = _string(v, consume buf, print_readably)
    end

    buf.push(finish)
    buf

  fun _string(
    value: MalType,
    buf': String iso,
    print_readably: Bool)
    : String iso^
  =>
    """
    Generate string representation of the given data.
    """
    var buf = consume buf'

    match value
    | None =>
      buf.append("nil")
    | let x: Bool =>
      buf.append(x.string())
    | let x: I64 =>
      buf.append(x.string())
    | let x: F64 =>
      buf.append(x.string())
    | let x: String =>
      // consume works, because we use reassign
      if print_readably then
        buf = _escaped_string(consume buf, x)
      else
        buf.append(x)
      end
    | let x: MalList =>
      buf = _string_array(x.value, consume buf, print_readably, '(', ')')
    | let x: MalVector =>
      buf = _string_array(x.value, consume buf, print_readably, '[', ']')
    | let x: MalMap =>
      buf = _string_map(x.value, consume buf, print_readably)
    | let x: MalSymbol =>
      buf.append(x.value)
    | let x: MalKeyword =>
      buf.append(x.value)
    | let x: NativeFunction =>
      buf.append("#<native function: " + x.name() + " >")
    | let x: MalLambda =>
      buf.append("#<function>")
    | let x: MalAtom =>
      buf.append("(atom ")
      buf = _string(x.value, consume buf, print_readably)
      buf.append(")")
    | let x: SpecialForm =>
      buf.append("#<special form: " + x.name() + " >")
    // | let x: SpecialFormTCO =>
    //   buf.append("#<special form: " + x.name() + ">")
    end

    buf

  fun _escaped_string(buf: String iso, s: String): String iso^ =>
    """
    Generate a version of the given string with escapes for all non-printable
    and non-ASCII characters.
    """
    var i: USize = 0

    buf.push('"')

    try
      while i < s.size() do
        (let c, let count) = s.utf32(i.isize())?
        i = i + count.usize()

        if c == '"' then
          buf.append("\\\"")
        elseif c == '\\' then
          buf.append("\\\\")
        elseif c == '\b' then
          buf.append("\\b")
        elseif c == '\f' then
          buf.append("\\f")
        elseif c == '\t' then
          buf.append("\\t")
        elseif c == '\r' then
          buf.append("\\r")
        elseif c == '\n' then
          buf.append("\\n")
        elseif (c >= 0x20) and (c < 0x80) then
          buf.push(c.u8())
        elseif c < 0x10000 then
          buf.append("\\u")
          buf.append(Format.int[U32](c where
            fmt = FormatHexBare, width = 4, fill = '0'))
        else
          let high = (((c - 0x10000) >> 10) and 0x3FF) + 0xD800
          let low = ((c - 0x10000) and 0x3FF) + 0xDC00
          buf.append("\\u")
          buf.append(Format.int[U32](high where
            fmt = FormatHexBare, width = 4))
          buf.append("\\u")
          buf.append(Format.int[U32](low where fmt = FormatHexBare, width = 4))
        end
      end
    end

    buf.push('"')
    buf

  fun print_str(value: MalType, print_readably: Bool = false): String iso^ =>
    _string(value, recover String(256) end, print_readably)
