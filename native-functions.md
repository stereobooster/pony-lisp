# How to implement native functions

We have 3 options on how to implement native functions

1. One big `match` expression
2. Lambdas in Lisp environment
3. Classes (or objects) in Lisp environment

Native function should provide `application` method:

```pony
fun apply(arr: Array[LispType]): LispType ?
```

In this case each function will have to privde it's own validation. Othe way would be to provide exact types and implement validate method in the same class:

```pony
fun validate(arr: Array[LispType]): Either<String, Array[I64]>
fun apply(arr: Array[I64]): LispType ?
```

One way or another we need a set of validators, for example

```pony
fun validateI64(arr: Array[LispType]): Either<String, Array[I64]>
fun validateLength(arr: Array[LispType], length: USize): Either<String, Array[LispType]>
```

It would be nice to implement composable validators, like in [`io-ts`](https://github.com/gcanti/io-ts/blob/master/Decoder.md), because otherwise we will have a lot of code repetition. But it is not possible, because recursive types are not allowed and I wasn't able to do some tricks with type restrictions either.

Validating array of integers is trivial. What about tuples? What about complex data structures, like hash maps of arbitrary shape?

One potential way to solve it is to write small code generator (which will generate all repitative code), but this is way too much work for small experiment.

## Final thoughts

For now each native function should provide validation

```pony
fun apply(arr: Array[LispType]): Either<String, LispType> ?
```

It would be nice to implement minimal set of validators, which will restrict to atomic types, like arrays of integers, floats, strings etc.

## Related

- https://github.com/mfelsche/pony-maybe/blob/master/maybe/maybe.pony
- https://gcanti.github.io/fp-ts/modules/Either.ts.html
- https://github.com/gcanti/fp-ts/blob/master/docs/guides/HKT.md
- https://dev.to/gcanti/getting-started-with-fp-ts-monad-6k
- https://typelevel.org/cats/datatypes/kleisli.html
- https://github.com/ponylang/ponyc/blob/master/packages/options/options.pony
