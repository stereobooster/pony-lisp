use "collections"

type Symbol is String             // A Scheme Symbol is implemented as a String
// Number = Number                // A Scheme Number is implemented as a Number
type Atom is (Symbol | Number)    // A Scheme Atom is a Symbol or Number
// List = list                    // A Scheme List is implemented as a List
// type Exp is (Atom, List[Exp])  // A Scheme expression is an Atom or List
type LispEnv is Map[Symbol, Node] // A Scheme environment

class DefaultEnv
  // https://www.ponylang.io/faq/#code-for-all-numbers
  fun call[T: U64](name: String, x: T, y: T): T ? =>
    match name
    | "+" => x + y
    | "-" => x - y
    | "*" => x * y
    | "/" => x / y
   // "abs":     abs,
   // "max":     max,
   // "min":     min,
   // "round":   round,
   // "expt":    pow,
   // ">":       op.gt,
   // "<":       op.lt,
   // ">=":      op.ge,
   // "<=":      op.le,
   // "=":       op.eq,
   // "eq?":     op.is_,
   // "equal?":  op.eq,
   // "not":     op.not_,
   // "apply":   lambda proc, args: proc(*args),
   // "begin":   lambda *x: x[-1],
   // "append":  op.add,
   // "car":     lambda x: x[0],
   // "cdr":     lambda x: x[1:],
   // "cons":    lambda x,y: [x] + y,
   // "length":  len,
   // "list":    lambda *x: List(x),
   // "map":     map,
   // "print":   print,
   // "list?":   lambda x: isinstance(x, List),
   // "null?":   lambda x: x == [],
   // "number?": lambda x: isinstance(x, Number),
   // "procedure?": callable,
   // "symbol?": lambda x: isinstance(x, Symbol),
    else
      error
    end
