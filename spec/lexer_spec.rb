require_relative "spec_helper"

describe Sherlock::Lexer do
  def token(*args)
    Sherlock::Lexer::Token.new(*args)
  end

  it "finds opening parens" do
    lexer = Sherlock::Lexer.new("(")
    expect(lexer.next).to eq(token(:paren, "("))
  end

  it "finds lambdas" do
    lexer = Sherlock::Lexer.new("lambda")
    expect(lexer.next).to eq(token(:keyword, "lambda"))
  end
end
