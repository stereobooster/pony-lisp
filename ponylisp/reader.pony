use "regex"
use "collections"

class Reader
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

fun tokenize(str: String): Array[String] ? =>
  let r = Regex("[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:[\\].|[^\\\"])*\"?|;.*|[^\\s\\[\\]{}()'\"`@,;]+)")?
  let matches = r.matches(str)
  let result: Array[String] = []
  for element in matches do
    if element(0)? != ";" then
      result.push(element(0)?)
    end
  end
  result

fun _keyword(str: String) =>
  // WTF is u00029E
  // if str.find("\u00029E")? == 0 then
  //   str
  // else
    "\u00029E" + str
  // end

fun read_atom(reader: Reader): Atom ? =>
  let token = reader.next()?

  let integer_r = Regex("^-?[0-9]+$")?
  let float_r = Regex("^-?[0-9][0-9.]*$")?
  let string_re = Regex("(?:[\\].|[^\\\"])*")?

  match token
  | "nil" => None
  | "true" => true
  | "false" => false
  | integer_r => token.u64()?
  | float_r => token.f64()?
  // TODO: parse escaped sequences https://stdlib.ponylang.io/src/json/json_doc/#L291
  | string_re => token.clone().strip("\"")
  else
    match token(0)?
    | '"' => error // "expected '\"', got EOF"
    | ':' => _keyword(token.cut(0, 1))
    else
      Symbol(token)
    end
  end

fun read_raw_list(reader: Reader, start: String, finish: String): Array[AstType] ? =>
  let list: Array[AstType] = []
  var token = reader.next()?
  if token != start then
    error // "expected '" + start + "'"
  end
  while (token = reader.peek()?) != finish do
    // if (token == None) {
    //   error // "expected '" + finish + "', got EOF"
    // end
    list.push(read_form(reader)?)
  end
  reader.next()?
  list

fun read_list(reader: Reader): ListType ? =>
  ListType(read_raw_list(reader, "(", ")")?, ListKind)

fun read_vector(reader: Reader): ListType ? =>
  ListType(read_raw_list(reader, "[", "]")?, VectorKind)

fun read_hash_map(reader: Reader): MapType ? =>
  let list = read_raw_list(reader, "{", "}")?
  if (list.size() %% 2) == 1 then
    error // "Odd number of hash map arguments"
  end
  let hash = Map[String, AstType](list.size()/2)
  var i: USize = 0
  while i < list.size() do
    match list(i)?
    | let key: String => hash(key) = list(i+1)?
    else
      error // non string key
    end
    i = i + 2
  end
  MapType(hash)

fun read_form(reader: Reader): AstType ? =>
  let token = reader.peek()?
  match token
  // reader macros/transforms
  | ";" => None
  | "\"" => reader.next()?
    return ListType([Symbol("quote"); read_form(reader)?])
  | "`" => reader.next()?
    return ListType([Symbol("quasiquote"); read_form(reader)?])
  | "~" => reader.next()?
    return ListType([Symbol("unquote"); read_form(reader)?])
  | "~@" => reader.next()?
    return ListType([Symbol("splice-unquote"); read_form(reader)?])
  | "^" => reader.next()?
      let meta = read_form(reader)?
      return ListType([Symbol("with-meta"); read_form(reader)?; meta])
  | "@" => reader.next()?
      return ListType([Symbol("deref"); read_form(reader)?])

  // list
  | ")" => error // "unexpected ')'"
  | "(" => return read_list(reader)?

  // vector
  | "]" => error // "unexpected ']'"
  | "[" => return read_vector(reader)?

  // hash-map
  | "}" => error // "unexpected '}'"
  | "{" => return read_hash_map(reader)?

  else 
    read_atom(reader)?
  end


fun read_str(str: String) ? =>
  let tokens = tokenize(str)?
  if tokens.size() == 0 then 
    error // empty input
  end
  let reader = Reader(tokens)
  read_form(reader)?
