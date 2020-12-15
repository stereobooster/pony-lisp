use "debug"
use "term"
use "promises"
use "collections"

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let _out: OutStream
  let _mal: Mal
  let _register: ErrorRegister
  
  new iso create(out: OutStream) =>
    _out = out
    _register = ErrorRegister(out)
    _mal = Mal(_register)

  fun ref apply(line: String, prompt: Promise[String]) =>
    try
      _out.print(_mal.rep(line)?)
    // else
    //   _out.print(_register.get().string())
    end
    // can't use "\n" here
    prompt("user>")

  fun ref tab(line: String): Seq[String] box => Array[String]

actor Main
  new create(env: Env) =>
    let handler = Handler(env.out)
    let readline = Readline(consume handler, env.out)
    let term = ANSITerm(consume readline, env.input)
    term.prompt("user> ")

    let notify = object iso
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end

    env.input(consume notify)
