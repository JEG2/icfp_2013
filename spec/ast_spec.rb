require_relative "spec_helper"

describe Sherlock::AST do
  def parser(expression)
    lexer  = Sherlock::Lexer.new(expression)
    parser = Sherlock::Parser.new(lexer)
  end

  it "knows the size of variables" do
    parser = parser("x")
    expect(parser.parse_variable.size).to eq(1)
  end

  it "knows the size of constants" do
    parser = parser("0")
    expect(parser.parse_constant.size).to eq(1)
  end

  it "knows the size of binary operators" do
    parser = parser("(plus 0 1)")
    expect(parser.parse_sexp.size).to eq(3)
  end

  it "knows the size of unary operators" do
    parser = parser("(not 1)")
    expect(parser.parse_sexp.size).to eq(2)
  end

  it "knows the size of if0 operators" do
    parser = parser("(if0 x y z)")
    expect(parser.parse_sexp.size).to eq(4)
  end

  it "knows the size of fold operators" do
    parser = parser("(fold x y (lambda (c f) 0))")
    expect(parser.parse_sexp.size).to eq(5)
  end

  it "knows the size of the program" do
    parser = parser("(lambda (x) 0)")
    expect(parser.parse.size).to eq(2)
  end

  it "identifies if0 operator" do
    parser = parser("(if0 x y z)")
    expect(parser.parse_sexp.operators).to eq(Set["if0"])
  end

  it "identifies fold operator" do
    parser = parser("(fold x y (lambda (c f) 0 ))")
    expect(parser.parse_sexp.operators).to eq(Set["fold"])
  end
  
  it "identifies unary operators" do
    parser = parser("(not 1)")
    expect(parser.parse_sexp.operators).to eq(Set["not"])
  end
  
  it "identifies binary operators" do
    parser = parser("(plus 0 1)")
    expect(parser.parse_sexp.operators).to eq(Set["plus"])
  end

  it "stringifies unary operators" do
    expression = "(shr1 1)"
    parser = parser(expression)
    expect(parser.parse_sexp.to_s).to eq(expression)
  end

  it "stringifies binary operators" do
    expression = "(plus 0 1)"
    parser = parser(expression)
    expect(parser.parse_sexp.to_s).to eq(expression)
  end

  it "stringifies constants" do
    constant = "1"
    parser = parser(constant)
    expect(parser.parse_constant.to_s).to eq(constant)
  end

  it "stringifies variables" do
    variable = "x"
    parser = parser(variable)
    expect(parser.parse_variable.to_s).to eq(variable)
  end

  it "stringifies fold" do
    expression = "(fold x y (lambda (c f) 1))"
    parser = parser(expression)
    expect(parser.parse_expression.to_s).to eq(expression)
  end

  it "stringifies if0" do
    expression = "(if0 x y z)"
    parser = parser(expression)
    expect(parser.parse_expression.to_s).to eq(expression)
  end
end
