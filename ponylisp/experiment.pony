// class Left[L]
//   let _value: L
//   new create(value: L) => _value = consume value
//   fun getValue(): this->L => _value

// class Right[R]
//   let _value: R
//   new create(value: R) => _value = consume value
//   fun getValue(): this->R => _value

// type Either[L, R] is (Left[L] | Right[R])

// // interface Decoder[T: LispType]
// interface Decoder[T]
//   fun ref decode(x: LispType): Either[String, T]

// class DecoderI64 is Decoder[I64]
//   fun ref decode(x: LispType): Either[String, I64] =>
//     match x
//     | let y: I64 => Right[I64](y)
//     else
//       Left[String]("Not an integer")
//     end

// class DecoderArray
//   var _d: Decoder[I64]
//   new create(d: Decoder[I64]) => 
//     _d = d
//   fun ref decode(x: Array[LispType]): Either[String, Array[I64]] =>
//     for v in x.values() do
//       match _d.decode(v)
//       | let l: Left[String] => return l
//       end
//     end
//     Right[Array[I64]](x as Array[I64])

// interface NativeFunction1[T]
//   fun box name(): String
//   fun box validate(arr: Array[T]): Either[String, Array[T]]
//   fun box apply(arr: Array[T]): LispType ?

// class PlusFunction1 is NativeFunction1[I64]
//   fun box name(): String => "+"

//   fun box validate(arr: Array[I64]): Either[String, Array[I64]] => 
//     DecoderArray[I64](DecoderI64).decode(arr)

//   fun box apply(arr: Array[I64]): LispType ? =>
//     if arr.size() < 2 then
//       error
//     end
//     var result: I64 = 0
//     for v in arr.values() do
//       result = result + v 
//     end
//     result