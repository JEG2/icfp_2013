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
end
