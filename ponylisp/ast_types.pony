use "debug"
use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors
// it is possible to confuse None or String from pony with values from Lisp,
// it would be more explicit if we provide wrappers fow all values, lik MalNone, MalString etc.
type MalAtom is (I64 | F64 | String | None | Bool | MalSymbol | MalKeyword)
type MalAst is (MalAtom | MalMap | MalList | MalVector)
type MalType is (MalAst | NativeFunction | MalLambda | SpecialForm)

type MalEnvData is (Map[String, MalType])
class MalEnv
  let _data: MalEnvData
  let _outer: (MalEnv | None)

  new create(outer: (MalEnv | None) = None, data: MalEnvData = MalEnvData(0)) =>
    _data = data
    _outer = outer

  fun ref get(key: String): MalType ? => 
    if _data.contains(key) then
      return _data(key)?
    end
    match _outer
    | None => error
    | let x: MalEnv => x.get(key)?
    end

  fun ref set(key: String, value: MalType) => 
    _data(key) = value

  fun ref find(key: String): (MalEnv | None) =>
    if _data.contains(key) then
      return this
    end
    match _outer
    | None => None
    | let x: MalEnv => x.find(key)
    end

class MalSymbol // is Stringable
  let value: String
  new create(value': String) =>
    value = value'
  // fun eq(that: box->MalSymbol): Bool =>
  //   this.value == that.value

class MalKeyword
  let value: String
  new create(value': String) =>
    value = value'

// we need those classes because Pony doesn't support recursive types
class MalList
  let value: Array[MalType]
  new create(value': Array[MalType]) =>
    value = value'
  fun ref getValue(): Array[MalType] => value

class MalVector
  let value: Array[MalType]
  new create(value': Array[MalType]) =>
    value = value'
  fun ref getValue(): Array[MalType] => value

class  MalMap
  let value: Map[String, MalType]
  new create(value': Map[String, MalType]) =>
    value = value'

class  MalLambda
  let arguments: Array[MalSymbol]
  let body: MalType
  let env: MalEnv
  new create(arguments': Array[MalSymbol], body': MalType, env': MalEnv) =>
    arguments = arguments'
    body = body'
    env = env'
