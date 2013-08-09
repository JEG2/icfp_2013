module Sherlock
  class Parser
    def initialize(lexer)
      @lexer = lexer
    end

    attr_reader :lexer
    private     :lexer

    def parse
      require_token("(")
      require_token("lambda")
      require_token("(")
      variable = parse_variable
      require_token(")")
      expression = parse_expression
      require_token(")")

      AST::Program.new(variable, expression)
    end

    def parse_expression
      parse_constant ||
      parse_variable ||
      parse_sexp
    end

    def parse_sexp
      require_token("(")
      result =
        parse_not   ||
        parse_shl1  ||
        parse_shr1  ||
        parse_shr4  ||
        parse_shr16 ||
        parse_and   ||
        parse_or    ||
        parse_xor   ||
        parse_plus  ||
        parse_if0   ||
        parse_fold
      require_token(")")
      result
    end

    def parse_not
      consume_token_if_present(content: "not") {
        AST::NotOperator.new(parse_expression)
      }
    end

    def parse_shl1
      consume_token_if_present(content: "shl1") {
        AST::ShiftLeftOne.new(parse_expression)
      }
    end

    def parse_shr1
      consume_token_if_present(content: "shr1") {
        AST::ShiftRightOne.new(parse_expression)
      }
    end

    def parse_shr4
      consume_token_if_present(content: "shr4") {
        AST::ShiftRightFour.new(parse_expression)
      }
    end

    def parse_shr16
      consume_token_if_present(content: "shr16") {
        AST::ShiftRightSixteen.new(parse_expression)
      }
    end

    def parse_and
      consume_token_if_present(content: "and") {
        AST::AndOperator.new(parse_expression, parse_expression)
      }
    end

    def parse_or
      consume_token_if_present(content: "or") {
        AST::OrOperator.new(parse_expression, parse_expression)
      }
    end

    def parse_xor
      consume_token_if_present(content: "xor") {
        AST::XorOperator.new(parse_expression, parse_expression)
      }
    end

    def parse_plus
      consume_token_if_present(content: "plus") {
        AST::PlusOperator.new(parse_expression, parse_expression)
      }
    end

    def parse_if0
      consume_token_if_present(content: "if0") {
        AST::IfOperator.new(parse_expression, parse_expression, parse_expression)
      }
    end

    def parse_fold
      consume_token_if_present(content: "fold") {
        folded_over = parse_expression
        initializer = parse_expression
        require_token("(")
        require_token("lambda")
        require_token("(")
        byte        = parse_variable
        accumulator = parse_variable
        require_token(")")
        expression  = parse_expression
        require_token(")")
        AST::Fold.new(folded_over, initializer, byte, accumulator, expression)
      }
    end
    
    def parse_variable
      consume_token_if_present(type: :variable) { |token|
        AST::Variable.new(token.content)
      }
    end

    def parse_constant
      consume_token_if_present(type: :constant) { |token|
        AST::Constant.new(token.content.to_i)
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
