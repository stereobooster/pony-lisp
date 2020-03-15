use "ponytest"
use ".."

actor CalculatorTest is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_CalculatorTestAddition)

class iso _CalculatorTestAddition is UnitTest
  fun name(): String => "addition"

  fun apply(h: TestHelper)? =>
    var t = Calculator.eval(Parser.parse("(+ 1 1)")?)?
    h.assert_eq[U64](2, t)
