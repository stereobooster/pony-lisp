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

  new create(kind': TokenKind, offset': USize) =>
    kind = kind'
    offset = offset'

primitive Tokenizer
  fun tokenize (from: String): Array[Token] ? =>
    var tokens: Array[Token] = tokens.create()
    var state: TokenizationState = NotInToken
    var i = USize(0)

    while i < from.size() do
      var c = from(i)?
      match c
        | '(' =>
          Debug("(")
          tokens.push(Token.create(OpeningParenthesis, i))
          state = NotInToken
        | ')' =>
          Debug(")")
          tokens.push(Token.create(ClosingParenthesis, i))
          state = NotInToken
        | ';' =>
          Debug("Comment")
          tokens.push(Token.create(Comment, i))
          while (i < from.size()) and (from(i)? != '\n') do
            i = i + 1
          end
          state = NotInToken
        | '\t' | '\r' | '\n' | ' ' =>
          Debug("Empty")
          state = NotInToken
        | let x: U8 =>
          Debug("Atom")
          if (state is NotInToken) then
            tokens.push(Token.create(Atom, i))
          end
          state = InToken
      end
      i = i + 1
    end

    tokens

