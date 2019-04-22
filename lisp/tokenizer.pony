primitive NotInoken
primitive InToken

type State is (NotInoken | InToken)

primitive OpeningParenthesis
primitive ClosingParenthesis
primitive Atom

type Kind is (OpeningParenthesis | ClosingParenthesis | Atom)

primitive AllocationError
primitive ParseError
primitive Success

type Status is (AllocationError | ParseError | Success)

class Token
   let kind: Kind
   let offset: U64

   new create(kind': Kind, offset': U64) =>
     kind = kind'
     offset = offset'

class Tokenizer
  let _tokens: Array[String] = _tokens.create()


