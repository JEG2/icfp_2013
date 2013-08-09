module Sherlock
  module AST
    class XorOperator
      def initialize(left_expression, right_expression)
        @left_expression, @right_expression = left_expression, right_expression
      end

      attr_reader :left_expression, :right_expression

      def size
        1 + @left_expression.size + @right_expression.size
      end
    end
  end
end
