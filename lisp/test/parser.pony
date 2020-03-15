use "ponytest"
use ".."

actor ParserTest is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_ParserTestEmpty)
    test(_ParserTestParenthesis)
    test(_ParserTestComment)
    test(_ParserTestAtom)
    // test(_ParserTestUnclosedParenthesis)

class iso _ParserTestEmpty is UnitTest
  fun name(): String => "empty string"

  fun apply(h: TestHelper)? =>
    var t = Parser.parse("")?
    h.assert_true(t.kind is RootNode)
    h.assert_eq[USize](0, t.children.size())

class iso _ParserTestParenthesis is UnitTest
  fun name(): String => "empty parenthesis"

  fun apply(h: TestHelper)? =>
    var t = Parser.parse("()")?
    h.assert_eq[USize](1, t.children.size())
    h.assert_true(t.children(0)?.kind is SExpression)
    h.assert_eq[USize](0, t.children(0)?.children.size())

class iso _ParserTestComment is UnitTest
  fun name(): String => "comment"

  fun apply(h: TestHelper)? =>
    var t = Parser.parse("(; comment\n)")?
    h.assert_eq[USize](1, t.children.size())
    h.assert_true(t.children(0)?.kind is SExpression)
    h.assert_eq[USize](0, t.children(0)?.children.size())

class iso _ParserTestAtom is UnitTest
  fun name(): String => "atom"

  fun apply(h: TestHelper)? =>
    var t = Parser.parse("(+ 1 1)")?

    h.assert_eq[USize](1, t.children.size())
    h.assert_true(t.children(0)?.kind is SExpression)
    h.assert_eq[USize](3, t.children(0)?.children.size())

// class iso _ParserTestUnclosedParenthesis is UnitTest
//   fun name(): String => "unclosed parenthesis"

//   fun apply(h: TestHelper)? =>
//     var t = Parser.parse("(+ 1 1")?

//     h.assert_eq[USize](1, t.children.size())
