primitive Calculator
  fun eval (node: Node): U64 ? =>
    match node.kind
      | RootNode => Calculator.eval(node.children(0)?)?
      | SExpression => Calculator.evalExpression(node.children)?
      | IntegerNode => node.content.u64()?
      // | StringNode => node.content
      // | BooleanNode => node.content == "#t"
    else
      error
    end

  fun evalExpression (nodes: Array[Node]): U64 ? =>
    if nodes.size() == 0 then
      error
    end

    let rest = nodes.slice(1, nodes.size())

    match nodes(0)?.content
      | "+" => Calculator.evalPlus(rest)?
      | "-" => Calculator.evalMinus(rest)?
      | "*" => Calculator.evalMultiplication(rest)?
      | "/" => Calculator.evalDivision(rest)?
    else
      error
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



