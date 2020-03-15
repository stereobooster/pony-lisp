use "regex"

primitive RootNode
primitive SExpression
primitive SymbolNode
// add support of negative values `-x` and floats `x.x`
primitive IntegerNode
primitive BooleanNode
// to support string nodes we need to handle ` `, `\"` in Tokenizer
primitive StringNode

type NodeKind is (
    RootNode | SExpression |
    SymbolNode | IntegerNode | BooleanNode | StringNode
)

type ParseResult is (USize, Node)

class Node
  let kind: NodeKind
  let content: String
  let children: Array[Node]

  new create(kind': NodeKind, content': String, children': Array[Node]) =>
    kind = kind'
    content = content'
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
        | let t: Token if t.kind is OpeningParenthesis =>
          (let j, let node) = Parser.parseTokens(tokens, i + 1)?
          children.push(node)
          i = j
        | let t: Token if t.kind is ClosingParenthesis =>
          break
        | let t: Token if t.kind is AtomToken =>
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
      | Regex("\\d+")? => Node(IntegerNode, token.content, [])
      // | "#t" => Node(BooleanNode, token.content, [])
      // | "#f" => Node(BooleanNode, token.content, [])
      // | Regex("\".*\"")? => Node(StringNode, token.content, [])
    else
      Node(SymbolNode, token.content, [])
    end
