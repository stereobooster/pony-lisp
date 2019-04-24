primitive Calculator
  fun eval (node: Node): U64 ? =>
    match node.kind
      | RootNode => Calculator.eval(node.children(0)?)?
      | SExpression => Calculator.evalExpression(node.children)?
      | IntegerNode => node.content.u64()?
    else
      U64(0)
    end

  fun evalExpression (nodes: Array[Node]): U64 ? =>
    if nodes.size() == 0 then
      return U64(0)
    end

    let rest = nodes.slice(1, nodes.size())

    match nodes(0)?.kind
      | Plus => Calculator.evalPlus(rest)?
      | Minus => Calculator.evalMinus(rest)?
      | Multiplication => Calculator.evalMultiplication(rest)?
      | Division => Calculator.evalDivision(rest)?
    else
      U64(0)
    end

  fun evalPlus (nodes: Array[Node]): U64 ? =>
    var result: U64 = Calculator.eval(nodes(0)?)?
    var i = USize(1)
    while (i < nodes.size()) do
      result = result + Calculator.eval(nodes(i)?)?
      i = i + 1
    end
    result

  fun evalMinus (nodes: Array[Node]): U64 ? =>
    var result: U64 = Calculator.eval(nodes(0)?)?
    var i = USize(1)
    while (i < nodes.size()) do
      result = result - Calculator.eval(nodes(i)?)?
      i = i + 1
    end
    result

  fun evalMultiplication (nodes: Array[Node]): U64 ? =>
    var result: U64 = Calculator.eval(nodes(0)?)?
    var i = USize(1)
    while (i < nodes.size()) do
      result = result * Calculator.eval(nodes(i)?)?
      i = i + 1
    end
    result

  fun evalDivision (nodes: Array[Node]): U64 ? =>
    var result: U64 = Calculator.eval(nodes(0)?)?
    var i = USize(1)
    while (i < nodes.size()) do
      result = result / Calculator.eval(nodes(i)?)?
      i = i + 1
    end
    result



