use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors

type Atom is (I64 | F64 | String | None | Bool | Symbol | Keyword)
type AstType is (Atom | MapType | ListType | VectorType)

class Symbol // is Stringable
  let value: String
  new create(value': String) =>
    value = value'
  // fun eq(that: box->Symbol): Bool =>
  //   this.value == that.value

class Keyword
  let value: String
  new create(value': String) =>
    value = value'

// we need those closses because Pony doesn't support recursive types
class ListType
  let value: Array[AstType]
  new create(value': Array[AstType]) =>
    value = value'

// we need those closses because Pony doesn't support recursive types
class VectorType
  let value: Array[AstType]
  new create(value': Array[AstType]) =>
    value = value'

class  MapType
  let value: Map[String, AstType]
  new create(value': Map[String, AstType]) =>
    value = value'
