use "ponytest"
use ".."

actor TokenizerTest is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestEmpty)
    test(_TestParenthesis)
    test(_TestComment)
    test(_TestAtomToken)

class iso _TestEmpty is UnitTest
  fun name(): String => "empty string"

  fun apply(h: TestHelper)? =>
    var t = Tokenizer.tokenize("")?
    h.assert_eq[USize](t.size(), 0)

class iso _TestParenthesis is UnitTest
  fun name(): String => "empty parenthesis"

  fun apply(h: TestHelper)? =>
    var t = Tokenizer.tokenize("()")?
    h.assert_eq[USize](t.size(), 2)

    h.assert_eq[USize](t(0)?.offset, 0)
    h.assert_true(t(0)?.kind is OpeningParenthesis)

    h.assert_eq[USize](t(1)?.offset, 1)
    h.assert_true(t(1)?.kind is ClosingParenthesis)

class iso _TestComment is UnitTest
  fun name(): String => "comment"

  fun apply(h: TestHelper)? =>
    var t = Tokenizer.tokenize("(; comment\n)")?
    h.assert_eq[USize](t.size(), 3)

    h.assert_eq[USize](t(1)?.offset, 1)
    h.assert_true(t(1)?.kind is Comment)
    h.assert_eq[String](t(1)?.content, "; comment")

class iso _TestAtomToken is UnitTest
  fun name(): String => "atom"

  fun apply(h: TestHelper)? =>
    var t = Tokenizer.tokenize("(cons 1)")?
    h.assert_eq[USize](t.size(), 4)

    h.assert_eq[USize](t(1)?.offset, 1)
    h.assert_true(t(1)?.kind is AtomToken)
    h.assert_eq[String](t(1)?.content, "cons")

    h.assert_eq[USize](t(2)?.offset, 6)
    h.assert_true(t(2)?.kind is AtomToken)
    h.assert_eq[String](t(2)?.content, "1")
