use "ponytest"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    TokenizerTest.make().tests(test)
    ParserTest.make().tests(test)
    CalculatorTest.make().tests(test)