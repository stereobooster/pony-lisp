use "debug"
use "term"
use "promises"
use "collections"

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let _out: OutStream
  let _mal: Mal

  new iso create(env: Env) =>
    _out = env.out
    // I tried to pass it outside, but error messages are killing me
    _mal = Mal(StandardEffectHandler(env))

  fun ref apply(line: String, prompt: Promise[String]) =>
    try
      _out.print(_mal.rep(line)?)
    end
    // can't use "\n" here
    prompt("user> ")

  fun ref tab(line: String): Seq[String] box => Array[String]

actor Main
  new create(env: Env) =>
    let mal = Mal(StandardEffectHandler(env))

    let start_loop = try
      // because make file passes arguments --exclude=integration --sequential
      env.args(1)?(0)? == '-'
    else
      true
    end

    if start_loop then
      let handler = Handler(env)
      let readline = Readline(consume handler, env.out)
      let term = ANSITerm(consume readline, env.input)
      try
        mal.rep("(println (str \"Mal [\" *host-language* \"]\"))")?
      end
      term.prompt("user> ")
      let notify = object iso
        fun ref apply(data: Array[U8] iso) => term(consume data)
        fun ref dispose() => term.dispose()
      end
      env.input(consume notify)
    else
      try
        mal.execute(env.args)?
      else
        env.exitcode(1)
      end
    end
