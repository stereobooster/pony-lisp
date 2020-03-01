use "collections"

type Symbol is String     // A Scheme Symbol is implemented as a String
// Number = Number        // A Scheme Number is implemented as a Number
type Atom1 is (Symbol | Number) // A Scheme Atom is a Symbol or Number
// List = list            // A Scheme List is implemented as a List
type Exp[A] is (Atom, List[A])  // A Scheme expression is an Atom or List
// Env    = dict             // A Scheme environment
