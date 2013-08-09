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

  it "finds closing parens" do
    lexer = Sherlock::Lexer.new(")")
    expect(lexer.next).to eq(token(:paren, ")"))
  end

  it "finds constant 0" do
    lexer = Sherlock::Lexer.new("0")
    expect(lexer.next).to eq(token(:constant, "0"))
  end

  it "finds constant 1" do
    lexer = Sherlock::Lexer.new("1")
    expect(lexer.next).to eq(token(:constant, "1"))
  end

  it "finds if0s" do
    lexer = Sherlock::Lexer.new("if0")
    expect(lexer.next).to eq(token(:keyword, "if0"))
  end

  it "finds folds" do
    lexer = Sherlock::Lexer.new("fold")
    expect(lexer.next).to eq(token(:keyword, "fold"))
  end

  it "finds not" do
    lexer = Sherlock::Lexer.new("not")
    expect(lexer.next).to eq(token(:unary, "not"))
  end
  
  it "finds shl1" do
    lexer = Sherlock::Lexer.new("shl1")
    expect(lexer.next).to eq(token(:unary, "shl1"))
  end
  
  it "finds shr1" do
    lexer = Sherlock::Lexer.new("shr1")
    expect(lexer.next).to eq(token(:unary, "shr1"))
  end
  
  it "finds shr4" do
    lexer = Sherlock::Lexer.new("shr4")
    expect(lexer.next).to eq(token(:unary, "shr4"))
  end
  
  it "finds shr16" do
    lexer = Sherlock::Lexer.new("shr16")
    expect(lexer.next).to eq(token(:unary, "shr16"))
  end

  it "finds and" do
    lexer = Sherlock::Lexer.new("and")
    expect(lexer.next).to eq(token(:binary, "and"))
  end
  
  it "finds or" do
    lexer = Sherlock::Lexer.new("or")
    expect(lexer.next).to eq(token(:binary, "or"))
  end
  
  it "finds xor" do
    lexer = Sherlock::Lexer.new("xor")
    expect(lexer.next).to eq(token(:binary, "xor"))
  end
  
  it "finds plus" do
    lexer = Sherlock::Lexer.new("plus")
    expect(lexer.next).to eq(token(:binary, "plus"))
  end

  it "finds variables" do
    lexer = Sherlock::Lexer.new("apples34")
    expect(lexer.next).to eq(token(:variable, "apples34"))
  end

  it "discards whitespace" do
    lexer = Sherlock::Lexer.new("( and )")
    lexer.next
    expect(lexer.next).to eq(token(:binary, "and"))
  end

  it "lexes a program" do
    lexer = Sherlock::Lexer.new("(lambda (x_10327) (fold x_10327 0 (lambda (x_10327 x_10328) (xor (plus (shl1 x_10327) x_10328) 1))))")
    [ token(:paren, "("),
      token(:keyword, "lambda"),
      token(:paren, "("),
      token(:variable, "x_10327"),
      token(:paren, ")"),
      token(:paren, "("),
      token(:keyword, "fold"),
      token(:variable, "x_10327"),
      token(:constant, "0"),
      token(:paren, "("),
      token(:keyword, "lambda"),
      token(:paren, "("),
      token(:variable, "x_10327"),
      token(:variable, "x_10328"),
      token(:paren, ")"),
      token(:paren, "("),
      token(:binary, "xor"),
      token(:paren, "("),
      token(:binary, "plus"),
      token(:paren, "("),
      token(:unary, "shl1"),
      token(:variable, "x_10327"),
      token(:paren, ")"),
      token(:variable, "x_10328"),
      token(:paren, ")"),
      token(:constant, "1"),
      token(:paren, ")"),
      token(:paren, ")"),
      token(:paren, ")"),
      token(:paren, ")"),
      nil
    ].each do |token|
      expect(lexer.next).to eq token
    end
  end  
end
