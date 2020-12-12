use "term"
use "promises"
use "collections"

type LispEnv is (Map[String, String])

// https://github.com/ponylang/ponyc/blob/master/examples/readline/main.pony
class Handler is ReadlineNotify
  let out: OutStream
  
  new iso create(out': OutStream) =>
    out = out'

  fun ref apply(line: String, prompt: Promise[String]) =>
    out.print(rep(line))
    // can't use "\n" here
    prompt("user>")

  fun ref tab(line: String): Seq[String] box => Array[String]

  fun read(str: String): AstType => None
  
  fun eval(ast: AstType, lisp_env: LispEnv): AstType => ast

  fun print(exp: AstType): String => ""

  fun rep (str: String): String => 
    print(eval(read(str), LispEnv()))

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
