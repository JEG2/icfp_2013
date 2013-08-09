describe Sherlock::AST do
  it "knows the size of binary operators" do
    lexer  = Sherlock::Lexer.new("(plus 0 1)")
    parser = Sherlock::Parser.new(lexer)
    expect(parser.parse_sexp.size).to eq(3)
  end
end
