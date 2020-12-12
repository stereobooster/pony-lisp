use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors

type Atom is (I64 | F64 | String | None | Bool | Symbol | Keyword)
type AstType is (Atom | MapType | ListType | VectorType)

// type TwoArgumentLambda[T] is ({(T, T): T})
// type NativeFunction is (TwoArgumentLambda[I64])
type NativeFunction is ({(I64, I64): I64})
type AstTypeAndNativeFunction is (AstType | NativeFunction)
type LispEnv is (Map[String, AstTypeAndNativeFunction])

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
  let value: Array[AstTypeAndNativeFunction]
  new create(value': Array[AstTypeAndNativeFunction]) =>
    value = value'

// we need those closses because Pony doesn't support recursive types
class VectorType
  let value: Array[AstTypeAndNativeFunction]
  new create(value': Array[AstTypeAndNativeFunction]) =>
    value = value'

class  MapType
  let value: Map[String, AstTypeAndNativeFunction]
  new create(value': Map[String, AstTypeAndNativeFunction]) =>
    value = value'
