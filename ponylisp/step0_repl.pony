use "term"
use "promises"

class Handler is ReadlineNotify
  let _commands: Array[String] = []

  fun ref apply(line: String, prompt: Promise[String]) =>
    prompt("user> " + line)

  fun ref tab(line: String): Seq[String] box => Array[String]

actor Main
  new create(env: Env) =>
    let readline = Readline(Handler, env.out)
    let term = ANSITerm(consume readline, env.input)
    term.prompt("user> ")

    let notify = object iso
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end

    env.input(consume notify)

// fun read(str) => str
// fun eval(ast, env) => ast
// fun print(exp) => exp
// fun rep = function(str) { return PRINT(EVAL(READ(str), {})); };
