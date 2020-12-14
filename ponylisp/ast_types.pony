use "debug"
use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors
type Atom is (I64 | F64 | String | None | Bool | Symbol | Keyword)
type AstType is (Atom | MapType | ListType | VectorType | ListTypeStrict[Atom])

type LispType is (AstType | NativeFunction)
type LispEnvData is (Map[String, LispType])

class LispEnv
  let _data: LispEnvData
  let _outer: (LispEnv | None)

  new create(outer: (LispEnv | None) = None, data: LispEnvData = LispEnvData(0)) =>
    _data = data
    _outer = outer

  fun ref get(key: String): LispType ? => 
    if _data.contains(key) then
      return _data(key)?
    end
    match _outer
    | None => error
    | let x: LispEnv => x.get(key)?
    end

  fun ref set(key: String, value: LispType) => 
    _data(key) = value

  fun ref find(key: String): (LispEnv | None) =>
    if _data.contains(key) then
      return this
    end
    match _outer
    | None => None
    | let x: LispEnv => x.find(key)
    end

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

// we need those classes because Pony doesn't support recursive types
class ListType
  let value: Array[LispType]
  new create(value': Array[LispType]) =>
    value = value'
  fun ref getValue(): Array[LispType] => value

class ListTypeStrict[T: LispType]
  let value: Array[T]
  new create(value': Array[T]) =>
    value = value'
  fun ref getValue(): Array[T] => value

class VectorType
  let value: Array[LispType]
  new create(value': Array[LispType]) =>
    value = value'
  fun ref getValue(): Array[LispType] => value

class  MapType
  let value: Map[String, LispType]
  new create(value': Map[String, LispType]) =>
    value = value'
