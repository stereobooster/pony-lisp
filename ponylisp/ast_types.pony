use "debug"
use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors

type Atom is (I64 | F64 | String | None | Bool | Symbol | Keyword)
type AstType is (Atom | MapType | ListType | VectorType)

// type TwoArgumentLambda[T] is ({(T, T): T})
// type NativeFunction is (TwoArgumentLambda[I64])
type NativeFunction is ({(I64, I64): I64})
type AstTypeAndNativeFunction is (AstType | NativeFunction)
type LispEnvData is (Map[String, AstTypeAndNativeFunction])

class LispEnv
  let _data: LispEnvData
  let _outer: (LispEnv | None)

  new create(outer: (LispEnv | None) = None, data: LispEnvData = LispEnvData(0)) =>
    _data = data
    _outer = outer

  fun ref get(key: String): AstTypeAndNativeFunction ? => 
    if _data.contains(key) then
      return _data(key)?
    end
    match _outer
    | None => error
    | let x: LispEnv => x.get(key)?
    end

  fun ref set(key: String, value: AstTypeAndNativeFunction) => 
    Debug("set " + key)
    _data(key) = value

  // I can't find a way to reference the object itself, like `this` or `self` 
  fun ref find(env: LispEnv, key: String): (LispEnv | None) =>
    if env._data.contains(key) then
      return env
    end
    match env._outer
    | None => None
    | let x: LispEnv => x.find(x, key)
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
  let value: Array[AstTypeAndNativeFunction]
  new create(value': Array[AstTypeAndNativeFunction]) =>
    value = value'

class VectorType
  let value: Array[AstTypeAndNativeFunction]
  new create(value': Array[AstTypeAndNativeFunction]) =>
    value = value'

class  MapType
  let value: Map[String, AstTypeAndNativeFunction]
  new create(value': Map[String, AstTypeAndNativeFunction]) =>
    value = value'
