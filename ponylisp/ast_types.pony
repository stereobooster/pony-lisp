use "collections"

type Atom is (U64 | F64 | String | None | Bool | Symbol)
type AstType is (Atom | MapType | ListType)

class Symbol
  let value: String
  new create(value': String) =>
    value = value'
  fun eq(that: box->Symbol): Bool =>
    this.value == that.value

primitive VectorKind
primitive ListKind
type CollectionKind is (VectorKind | ListKind)

// we need those closses because Pony doesn't support recursive types
class ListType
  let data: Array[AstType]
  let kind: CollectionKind
  new create(data': Array[AstType], kind': CollectionKind = ListKind) =>
    data = data'
    kind = kind'
  fun ref get (): Array[AstType] =>
    data

class  MapType
  let data: Map[String, AstType]
  new create(data': Map[String, AstType]) =>
    data = data'
  fun ref get (): Map[String, AstType] =>
    data
