require_relative "spec_helper"

describe Sherlock::Parser do
  def parser(program)
    lexer  = Sherlock::Lexer.new(program)
    parser = Sherlock::Parser.new(lexer)
  end

  it "parses variables" do
    variable = parser("var").parse_variable
    expect(variable).to be_an_instance_of(Sherlock::AST::Variable)
    expect(variable.name).to eq("var")
  end

  it "parses not operators" do
    operator = parser("(not x)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::NotOperator)
    expression = operator.expression
    expect(expression).to be_an_instance_of(Sherlock::AST::Variable)
    expect(expression.name).to eq("x")
  end

  it "parses constants" do
    constant = parser("1").parse_constant
    expect(constant).to be_an_instance_of(Sherlock::AST::Constant)
    expect(constant.value).to eq(1)
  end

  it "parses shl1 operators" do
    operator = parser("(shl1 x)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::ShiftLeftOne)

    expression = operator.expression
    expect(expression).to be_an_instance_of(Sherlock::AST::Variable)
    expect(expression.name).to eq("x")
  end

  it "parses shr1 operators" do
    operator = parser("(shr1 x)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::ShiftRightOne)

    expression = operator.expression
    expect(expression.name). to eq("x")
  end

  it "parses shr4 operators" do
    operator = parser("(shr4 x)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::ShiftRightFour)

    expression = operator.expression
    expect(expression.name). to eq("x")
  end

  it "parses shr16 operators" do
    operator = parser("(shr16 x)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::ShiftRightSixteen)

    expression = operator.expression
    expect(expression.name).to eq("x")
  end

  it "parses and operators" do
    operator = parser("(and x y)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::AndOperator)

    left_expression  = operator.left_expression
    right_expression = operator.right_expression

    expect(left_expression.name).to eq("x")
    expect(right_expression.name).to eq("y")
  end

  it "parses or operators" do
    operator = parser("(or x y)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::OrOperator)

    left_expression  = operator.left_expression
    right_expression = operator.right_expression

    expect(left_expression.name ).to eq("x")
    expect(right_expression.name).to eq("y")
  end

  it "parses xor operators" do
    operator = parser("(xor x y)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::XorOperator)

    left_expression  = operator.left_expression
    right_expression = operator.right_expression

    expect(left_expression.name ).to eq("x")
    expect(right_expression.name).to eq("y")
  end

  it "parses plus operators" do
    operator = parser("(plus x y)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::PlusOperator)

    left_expression  = operator.left_expression
    right_expression = operator.right_expression

    expect(left_expression.name ).to eq("x")
    expect(right_expression.name).to eq("y")
  end

  it "parses if0 operators" do
    operator = parser("(if0 x y z)").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::IfOperator)

    condition   = operator.condition
    consequence = operator.consequence
    alternative = operator.alternative

    expect(condition.name  ).to eq("x")
    expect(consequence.name).to eq("y")
    expect(alternative.name).to eq("z")
  end

  it "parses fold operators" do
    operator = parser("(fold x y (lambda (c f) 0))").parse_sexp
    expect(operator).to be_an_instance_of(Sherlock::AST::Fold)

    folded_over = operator.folded_over
    initializer = operator.initializer
    byte        = operator.byte
    accumulator = operator.accumulator
    expression  = operator.expression

    expect(folded_over.name).to eq("x")
    expect(initializer.name).to eq("y")
    expect(byte.name       ).to eq("c")
    expect(accumulator.name).to eq("f")
    expect(expression.value).to eq(0)
  end

  it "parses a program" do
    operator = parser("(lambda (c) 0)").parse

    variable   = operator.variable
    expression = operator.expression

    expect(variable.name).to eq("c")
    expect(expression.value).to eq(0)
  end

  it "parses an example" do
    program = parser(<<-END_SEXP).parse
    (lambda (x_10327)
      (fold x_10327 0 (lambda (x_10327 x_10328)
                        (xor (plus (shl1 x_10327) x_10328) 1))))
    END_SEXP

    expect(program).to be_an_instance_of(Sherlock::AST::Program)
    expect(program.variable.name).to eq("x_10327")

    fold         = program.expression
    folded_over  = fold.folded_over
    initializer  = fold.initializer
    byte         = fold.byte
    accumulator  = fold.accumulator
    expression   = fold.expression
    
    expect(fold             ).to be_an_instance_of(Sherlock::AST::Fold)
    expect(folded_over.name ).to eq("x_10327")
    expect(initializer.value).to eq(0)
    expect(byte.name        ).to eq("x_10327")
    expect(accumulator.name ).to eq("x_10328")
    expect(expression).to be_an_instance_of(Sherlock::AST::XorOperator)

    xor_left_expression  = expression.left_expression
    xor_right_expression = expression.right_expression
    
    expect(xor_left_expression).to be_an_instance_of(Sherlock::AST::PlusOperator)
    expect(xor_right_expression.value).to eq(1)

    plus_left_expression  = xor_left_expression.left_expression
    plus_right_expression = xor_left_expression.right_expression

    expect(plus_left_expression).to be_an_instance_of(Sherlock::AST::ShiftLeftOne)
    expect(plus_right_expression.name).to eq("x_10328")

    shift_left_one = plus_left_expression.expression
    expect(shift_left_one.name).to eq("x_10327")
  end
end
