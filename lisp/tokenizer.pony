use "debug"

primitive NotInToken
primitive InToken

type TokenizationState is (NotInToken | InToken)

primitive OpeningParenthesis
primitive ClosingParenthesis
primitive Comment
primitive Atom

type TokenKind is (OpeningParenthesis | ClosingParenthesis | Atom | Comment)

class Token
  let kind: TokenKind
  let offset: USize
  let content: String

  new create(kind': TokenKind, offset': USize, content': String) =>
    kind = kind'
    offset = offset'
    content = content'

primitive Tokenizer
  fun tokenize (source: String): Array[Token] ? =>
    var tokens: Array[Token] = []
    var state: TokenizationState = NotInToken
    var i = USize(0)
    var token = ""
    var atomStart = USize(0)

    while i < source.size() do
      var char = source(i)?
      match char
        | '(' =>
          // Debug("(")
          if (state is InToken) then
            tokens.push(Token(Atom, atomStart, token))
            token = ""
          end
          tokens.push(Token(OpeningParenthesis, i, "("))
          state = NotInToken
          token = ""

        | ')' =>
          // Debug(")")
          if (state is InToken) then
            tokens.push(Token(Atom, atomStart, token))
            token = ""
          end
          tokens.push(Token(ClosingParenthesis, i, ")"))
          state = NotInToken
          token = ""

        | ';' =>
          // Debug("Comment")
          if (state is InToken) then
            tokens.push(Token(Atom, atomStart, token))
            token = ""
          end
          var commentStart = i
          while (i < source.size()) and (source(i)? != '\n') do
            char = source(i)?
            // token.push(char)
            token = token.add(String.from_array([char]))
            i = i + 1
          end
          tokens.push(Token(Comment, commentStart, token))
          state = NotInToken
          token = ""

        | '\t' | '\r' | '\n' | ' ' =>
          // Debug("Empty")
          if (state is InToken) then
            tokens.push(Token(Atom, atomStart, token))
            token = ""
          end
          state = NotInToken

        | let x: U8 =>
          // Debug("Atom")
          if (state is NotInToken) then
            atomStart = i
          end
          state = InToken
          // token.push(char)
          token = token.add(String.from_array([char]))
      end
      i = i + 1
    end

    tokens

