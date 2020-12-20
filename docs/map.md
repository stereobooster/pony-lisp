MAL implements idea of gamification. It has 10 levels followed one by one. Also it has optional steps, but it is not always clear what is optional.

What if instead of linear 10 steps there would be a 2d map (think of D&D map or Snake and Leader), where you can make choices and depending on your choices you can build different language with different tradeofs, for example: mutable vs immutable variables, static types vs dynamic types, compiled vs interpreted. Or for example show how some features are interchangable, for example `let` can be implemented as special form or as macro which uses function for binding.

To be continued...

Legend:

```mermaid
graph TB
1([Check point])
2[Step]
3[[Types]]
4>Errors]
5{{Special form}}
6[/Native functions/]
```

```mermaid
graph TB
echo([echo])
stokenizer[Split tokenizer]
parser[parser]
emptyeval[empty eval]
rtokenizer[Regex tokenizer]
peg[PEG]
repl([REPL])
numbers[[Numbers]]
env[Environment]
math[/"+, -, *, / ..."/]
compare[/">, <, = ..."/]
lfunctions[/"empty?, list, first, rest"/]
calcy([calcy])
functions([functions])
serrors>Syntax errors]
uerror>Undefined error]
terror>type errors]
variables
lambdas
nil[Null or nil]
fn{{fn}}
def{{def}}
do{{do}}
if{{if}}
quote{{quote}}
symbols[[symbols]]
tco([Tail call optimization])
quasiquote{{quasiquote}}
lists[[lists]]
ftype[[function type]]
boolean[[Boolean]]
merror>Out of memory error]
rerror>"Stack overflow or infinite loop"]

echo ==> stokenizer

subgraph reader
stokenizer ==> parser
rtokenizer --> parser
peg -.- parser
parser -.- serrors
parser -.- astsymbols[[AST symbols]]
parser -.- astlists[[AST lists]]
end

parser ==> printer
printer ==> emptyeval
emptyeval ==> repl

repl ==> env
env ==> variables
variables -.- uerror
variables --> nil
variables ==> functions
echo --> rtokenizer

echo --> peg
repl --> numbers
repl --> math
math --> calcy
math -.- terror
functions -.- terror
numbers --> calcy
variables --> def

functions -.- fn
functions --> do

do --> tco
if --> tco
if -.- boolean

functions --> quote

fn -.- ftype
math -.- ftype
env -.- merror
functions --> recursion
recursion -.- rerror
rerror --> tco


numbers --> compare
boolean --> compare
lists --> lfunctions

quote -.- symbols
quote -.- lists
```
