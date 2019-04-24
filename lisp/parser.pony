use "regex"

primitive RootNode
primitive SExpression

// algebra
primitive Plus
primitive Minus
primitive Multiplication
primitive Division
primitive IntegerNode

type NodeKind is (
    RootNode | SExpression | Atom
  | Plus | Minus | Multiplication | Division | IntegerNode
)

type ParseResult is (USize, Node)

class Node
  let kind: NodeKind
  let contnent: String
  let children: Array[Node]

  new create(kind': NodeKind, contnent': String, children': Array[Node]) =>
    kind = kind'
    contnent = contnent'
    children = children'

primitive Parser
  fun parse (source: String): Node ? =>
    (let j, let node) = Parser.parseTokens(Tokenizer.tokenize(source)?, USize(0))?
    node

  fun parseTokens(tokens: Array[Token], position: USize): ParseResult ?  =>
    var i = position
    var children: Array[Node] = []

    while i < tokens.size() do
      var token = tokens(i)?
      match token
        | let x: Token if x.kind is OpeningParenthesis =>
          (let j, let node) = Parser.parseTokens(tokens, i + 1)?
          children.push(node)
          i = j
        | let x: Token if x.kind is ClosingParenthesis =>
          break
        | let t: Token if t.kind is Atom =>
          children.push(Parser.parseAtom(t)?)
          i = i + 1
        | let t: Token if t.kind is Comment =>
          // children.push(Node(Comment, t.content, []))
          i = i + 1
      end
    end

    (i, Node(if (position == 0) then RootNode else SExpression end, "", children))

  fun parseAtom(token: Token): Node ? =>
    match token.content
      | "+" => return Node(Plus, token.content, [])
      | "-" => return Node(Minus, token.content, [])
      | "*" => return Node(Multiplication, token.content, [])
      | "/" => return Node(Division, token.content, [])
      | Regex("\\d+")? => return Node(IntegerNode, token.content, [])
    else
      return Node(Atom, token.content, [])
    end
