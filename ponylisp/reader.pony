use "regex"
use "collections"
use "json"
// use "debug"

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
      // result.push(Token(element(1)?, element.start_pos(), element.end_pos()))
      if element(1)?(0)? != ';' then
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
  let _eh: ErrorHandler

  new create(eh: ErrorHandler) ? =>
    _integer_r = Regex("^-?[0-9]+$")?
    _float_r = Regex("^-?[0-9][0-9.]*$")?
    _string_r = Regex(""""(?:[\\].|[^\\"])*"""")?
    _eh = eh

  fun read_primitive(stream: TokenStream): MalPrimitive ? =>
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
        _eh.err("expected '\"', got EOF")
        error
      // "\u029e" is ʞ, not sure why MAL chose to do it this way
      // | ':' => ";\u029e" + token.cut(0, 1)
      | ':' => MalKeyword(token)
      // | ';' => None // comment
      else
        MalSymbol(token)
      end
    end

  fun read_sequence(stream: TokenStream, start: String, finish: String): Array[MalType] ? =>
    let list: Array[MalType] = []
    var token = stream.next()?
    if token != start then
      _eh.err("expected '" + start + "'")
      error
    end
    try
      while stream.peek()? != finish do
        let x = read_form(stream)?
        list.push(x)
      end
    else
      _eh.err("expected '" + finish + "', got EOF")
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
      _eh.err("odd number of hash map arguments")
      error
    end
    let hash = Map[String, MalType](list.size()/2)
    var i: USize = 0
    while i < list.size() do
      match list(i)?
      | let key: String => hash(key) = list(i+1)?
      | let key: MalKeyword => hash(key.value) = list(i+1)?
      // | let key: MalSymbol => hash(key.value) = list(i+1)?
      else
        _eh.err("key not a string")
        error
      end
      i = i + 2
    end
    MalMap(hash)

  fun read_form(stream: TokenStream): MalType ? =>
    let token = stream.peek()?
    match token
    // stream macros/transforms
    | "'" => stream.next()?
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
      _eh.err("unexpected ')'")
      error
    | "(" => read_list(stream)?

    // vector
    | "]" =>
      _eh.err("unexpected ']'")
      error
    | "[" => read_vector(stream)?

    // hash-map
    | "}" =>
      _eh.err("unexpected '}'")
      error
    | "{" => read_hash_map(stream)?

    else
      read_primitive(stream)?
    end

  fun read_str(str: String): MalType ? =>
    let tokens = Tokenizer.tokenize(str)?
    if tokens.size() == 0 then
      _eh.err("empty input")
      None
    end
    read_form(TokenStream(tokens))?
