use "regex"
use "collections"
use "debug"
use "json"

// There seems to ba a bug in Pony type checker - it doesn't allow me to use MalAst here
// instead it forces me to use MalType

class Token
  let content: String
  let start: USize
  let finish: USize

  new create(content': String, start': USize, finish': USize) =>
    content = content'
    start = start'
    finish = finish'

primitive Tokenizer
  fun tokenize(str: String): Array[String] ? =>
    // official version
    // let r = Regex("""[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)""")?
    // version copied from Python implementation
    let r = Regex("""[\s,]*(~@|[\[\]{}()'`~^@]|"(?:[\\].|[^\\"])*"?|;.*|[^\s\[\]{}()'"`@,;]+)""")?
    let matches = r.matches(str)
    let result: Array[String] = []
    for element in matches do
      // ignore comments
      if element(1)? != ";" then
        // Debug(element.start_pos())
        // result.push(Token(element(1)?, element.start_pos(), element.end_pos()))
        result.push(element(1)?)
      end
    end
    result

class TokenStream
  let _tokens: Array[String]
  var _position: USize
  new create(tokens: Array[String], position: USize = 0) =>
    _tokens = tokens
    _position = position

  fun ref next(): String ? =>
    _position = _position + 1
    _tokens(_position - 1)?

  fun peek(): String ? => 
    _tokens(_position)? 
    // try
    //   _tokens(_position)
    // else
    //   None
    // end

// technically it's Parser, but MAL calls it Reader
class Reader
  let _integer_r: Regex
  let _float_r: Regex
  let _string_r: Regex
  new create() ? =>
    _integer_r = Regex("^-?[0-9]+$")?
    _float_r = Regex("^-?[0-9][0-9.]*$")?
    _string_r = Regex(""""(?:[\\].|[^\\"])*"""")?

  fun debug_val(value: MalType) =>
    match value
    | None => Debug(None)
    | let x: Bool => Debug(x)
    | let x: I64 => Debug(x)
    | let x: F64 => Debug(x)
    | let x: String => Debug("String"); Debug(x)
    | let x: MalList => Debug("MalList")
    | let x: MalVector => Debug("MalVector")
    | let x: MalMap => Debug("MalMap")
    | let x: MalSymbol => Debug("MalSymbol"); Debug(x.value)
    | let x: MalKeyword => Debug("MalKeyword"); Debug(x.value)
    end

  fun read_atom(stream: TokenStream): MalAtom ? =>
    let token = stream.next()?

    match token
    | "nil" => None
    | "true" => true
    | "false" => false
    | _integer_r => token.i64()?
    | _float_r => token.f64()?
    | _string_r =>
      let parser = JsonDoc
      parser.parse(token)?
      match parser.data
      | let x: String => x
      else
        // can't happen because we match string before with _string_r
        error
      end
    else
      match token(0)?
      | '"' =>
        Debug("expected '\"', got EOF")
        error
      // "\u029e" is ʞ, not sure why MAL chose to do it this way
      // | ':' => ";\u029e" + token.cut(0, 1)
      | ':' => MalKeyword(token)
      else
        MalSymbol(token)
      end
    end

  fun read_sequence(stream: TokenStream, start: String, finish: String): Array[MalType] ? =>
    let list: Array[MalType] = []
    var token = stream.next()?
    if token != start then
      Debug("expected '" + start + "'")
      error
    end
    try
      while stream.peek()? != finish do
        let x = read_form(stream)?
        list.push(x)
      end
    else
      Debug("expected '" + finish + "', got EOF")
      error
    end
    stream.next()?
    list

  fun read_list(stream: TokenStream): MalList ? =>
    MalList(read_sequence(stream, "(", ")")?)

  fun read_vector(stream: TokenStream): MalVector ? =>
    MalVector(read_sequence(stream, "[", "]")?)

  fun read_hash_map(stream: TokenStream): MalMap ? =>
    let list = read_sequence(stream, "{", "}")?
    if (list.size() %% 2) == 1 then
      Debug("odd number of hash map arguments")
      error
    end
    let hash = Map[String, MalType](list.size()/2)
    var i: USize = 0
    while i < list.size() do
      match list(i)?
      | let key: String => hash(key) = list(i+1)?
      // | let key: MalSymbol => hash(key.value) = list(i+1)?
      else
        Debug("key not a string")
        error
      end
      i = i + 2
    end
    MalMap(hash)

  fun read_form(stream: TokenStream): MalType ? =>
    let token = stream.peek()?
    match token
    // stream macros/transforms
    | ";" => None
    | "\"" => stream.next()?
      return MalList([MalSymbol("quote"); read_form(stream)?])
    | "`" => stream.next()?
      return MalList([MalSymbol("quasiquote"); read_form(stream)?])
    | "~" => stream.next()?
      return MalList([MalSymbol("unquote"); read_form(stream)?])
    | "~@" => stream.next()?
      return MalList([MalSymbol("splice-unquote"); read_form(stream)?])
    | "^" => stream.next()?
        let meta = read_form(stream)?
        return MalList([MalSymbol("with-meta"); read_form(stream)?; meta])
    | "@" => stream.next()?
        return MalList([MalSymbol("deref"); read_form(stream)?])

    // list
    | ")" => 
      Debug("unexpected ')'")
      error
    | "(" => read_list(stream)?

    // vector
    | "]" =>
      Debug("unexpected ']'")
      error
    | "[" => read_vector(stream)?

    // hash-map
    | "}" => 
      Debug("unexpected '}'")
      error
    | "{" => read_hash_map(stream)?

    else
      read_atom(stream)?
    end

  fun read_str(str: String): MalType ? =>
    let tokens = Tokenizer.tokenize(str)?
    if tokens.size() == 0 then
      Debug("empty input")
      error
    end
    read_form(TokenStream(tokens))?
