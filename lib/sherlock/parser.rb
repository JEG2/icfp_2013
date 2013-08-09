module Sherlock
  class Parser
    def initialize(lexer)
      @lexer = lexer
    end

    attr_reader :lexer
    private     :lexer

    def parse
      # ...
    end

    def parse_expression
      # parse_constant ||
      parse_variable ||
      parse_sexp
    end

    def parse_sexp
      require_token("(")
      result = parse_not
      require_token(")")
      result
    end

    def parse_not
      consume_token_if_present(content: "not") {
        AST::NotOperator.new(parse_expression)
      }
    end

    def parse_variable
      consume_token_if_present(type: :variable) { |token|
        AST::Variable.new(token.content)
      }
    end

    private

    def require_token(content)
      token = lexer.next
      fail "Parse error:  expected #{content}" unless token.content == content
    end

    def consume_token_if_present(match, &ast_builder)
      token = lexer.peek
      if token                                                        &&
         (!match.include?(:type)    || token.type    == match[:type]) &&
         (!match.include?(:content) || token.content == match[:content])
        yield lexer.next
      end
    end
  end
end
