use "collections"

type MalEnvData is (Map[String, MalType])
// TODO: use persistent hashmap
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

  // to define variables at global scope
  fun ref root(): MalEnv  =>
    match _outer
    | None => this
    | let x: MalEnv => x.root()
    end
