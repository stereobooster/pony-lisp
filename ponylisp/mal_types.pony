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
  new create(value': Array[MalType]) => value = value'
  // uniuons doesn't work with fields
  fun ref get_value(): Array[MalType] => value

class MalVector
  let value: Array[MalType]
  new create(value': Array[MalType]) => value = value'
  // uniuons doesn't work with fields
  fun ref get_value(): Array[MalType] => value

class  MalMap
  let value: Map[String, MalType]
  new create(value': Map[String, MalType]) => value = value'

class  MalLambda
  let argument_names: Array[MalSymbol]
  let body: MalType
  let env: MalEnv
  let is_macro: Bool
  new create(argument_names': Array[MalSymbol], body': MalType, env': MalEnv, is_macro': Bool = false) =>
    argument_names = argument_names'
    body = body'
    env = env'
    is_macro = is_macro'

primitive MalTypeUtils
  fun type_of(value: MalType): String val =>
    match value
    | None => "nil"
    | let x: Bool => "Bool"
    | let x: I64 => "I64"
    | let x: F64 => "F64"
    | let x: String => "String"
    | let x: MalList => "List"
    | let x: MalVector => "Vector"
    | let x: MalMap => "Map"
    | let x: MalSymbol => "Symbol"
    | let x: MalKeyword => "Keyword"
    | let x: NativeFunction => "NativeFunction"
    | let x: MalLambda => "Lambda"
    | let x: MalAtom => "Atom"
    | let x: SpecialForm => "SpecialForm"
    // | let x: SpecialFormTCO => Debug("SpecialFormTCO"); Debug(x.name())
    end

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

  fun eq(first: MalType, second: MalType): Bool =>
    match first
    | let first': I64 =>
      match second
      | let second': I64 => return first' == second'
      end
    | let first': F64 =>
      match second
      | let second': F64 => return first' == second'
      end
    | let first': String =>
      match second
      | let second': String => return first' == second'
      end
    | let first': None =>
      match second
      | let second': None => return first' == second'
      end
    | let first': Bool =>
      match second
      | let second': Bool => return first' == second'
      end
    | let first': MalSymbol =>
      match second
      | let second': MalSymbol => return first' == second'
      end
    | let first': MalKeyword =>
      match second
      | let second': MalKeyword => return first' == second'
      end
    | let first': MalMap =>
      match second
      | let second': MalMap => return first' is second'
      end
    | let first': (MalList| MalVector) =>
      match second
      | let second': (MalList| MalVector) =>
        if first'.get_value() is second'.get_value() then
          return true
        end
        if first'.get_value().size() != second'.get_value().size() then
          return false
        end
        try
          for (k, v) in first'.get_value().pairs() do
            if not eq(v, second'.get_value()(k)?) then
              return false
            end
          end
          return true
        else
          return false
        end
      end
    | let first': NativeFunction =>
      match second
      | let second': NativeFunction => return first' is second'
      end
    | let first': MalLambda =>
      match second
      | let second': MalLambda => return first' is second'
      end
    | let first': MalAtom =>
      match second
      | let second': MalAtom => return first' is second'
      end
    | let first': SpecialForm =>
      match second
      | let second': SpecialForm => return first' is second'
      end
    // | let first': SpecialFormTCO =>
    //   match second
    //   | let second': SpecialFormTCO => first' is second'
    //   end
    end
    false