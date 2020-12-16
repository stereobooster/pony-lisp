use "debug"
use "collections"

// TODO: AstNode which will contain position, so it would be easier to report parse errors
// it is possible to confuse None or String from pony with values from Lisp,
// it would be more explicit if we provide wrappers fow all values, lik MalNone, MalString etc.
type MalPrimitive is (I64 | F64 | String | None | Bool | MalSymbol | MalKeyword)
type MalAst is (MalPrimitive | MalMap | MalList | MalVector)
type MalType is (MalAst | MalAtom | MalLambda | NativeFunction | SpecialForm ) //| SpecialFormTCO

class MalSymbol is Equatable[MalSymbol]
  let value: String
  new create(value': String) =>
    value = value'
  fun box eq(that: box->MalSymbol): Bool =>
    value == that.value

class MalKeyword is Equatable[MalKeyword]
  let value: String
  new create(value': String) =>
    value = value'
  fun box eq(that: box->MalKeyword): Bool =>
    value == that.value

class MalAtom
  var value: MalType
  new create(value': MalType) =>
    value = value'

// we need those classes because Pony doesn't support recursive types
class MalList
  let value: Array[MalType]
  new create(value': Array[MalType]) =>
    value = value'

class MalVector
  let value: Array[MalType]
  new create(value': Array[MalType]) =>
    value = value'

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

primitive MalTypeUtils
  fun debug_val(value: MalType) =>
    match value
    | None => Debug(None)
    | let x: Bool => Debug(x)
    | let x: I64 => Debug(x)
    | let x: F64 => Debug(x)
    | let x: String => Debug("String"); Debug(x)
    | let x: MalList => Debug("MalList")
    | let x: MalVector => Debug("MalVector")
    | let x: MalMap => Debug("MalMap")
    | let x: MalSymbol => Debug("MalSymbol"); Debug(x.value)
    | let x: MalKeyword => Debug("MalKeyword"); Debug(x.value)
    | let x: NativeFunction => Debug("NativeFunction"); Debug(x.name())
    | let x: MalLambda => Debug("MalLambda")
    | let x: MalAtom => Debug("MalAtom")
    | let x: SpecialForm => Debug("SpecialForm"); Debug(x.name())
    // | let x: SpecialFormTCO => Debug("SpecialFormTCO"); Debug(x.name())
    end

  fun eq(first: MalType, second: MalType): (Bool | None) =>
    match first
    | let first': I64 =>
      match second
      | let second': I64 => first' == second'
      end
    | let first': F64 =>
      match second
      | let second': F64 => first' == second'
      end
    | let first': String =>
      match second
      | let second': String => first' == second'
      end
    | let first': None =>
      match second
      | let second': None => first' == second'
      end
    | let first': Bool =>
      match second
      | let second': Bool => first' == second'
      end
    | let first': MalSymbol =>
      match second
      | let second': MalSymbol => first' == second'
      end
    | let first': MalKeyword =>
      match second
      | let second': MalKeyword => first' == second'
      end
    | let first': MalMap =>
      match second
      | let second': MalMap => first' is second'
      end
    | let first': MalList =>
      match second
      | let second': MalList => first' is second'
      end
    | let first': MalVector =>
      match second
      | let second': MalVector => first' is second'
      end
    | let first': NativeFunction =>
      match second
      | let second': NativeFunction => first' is second'
      end
    | let first': MalLambda =>
      match second
      | let second': MalLambda => first' is second'
      end
    | let first': MalAtom =>
      match second
      | let second': MalAtom => first' is second'
      end
    | let first': SpecialForm =>
      match second
      | let second': SpecialForm => first' is second'
      end
    // | let first': SpecialFormTCO =>
    //   match second
    //   | let second': SpecialFormTCO => first' is second'
    //   end
    end