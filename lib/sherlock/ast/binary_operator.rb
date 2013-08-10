require_relative "expression"

module Sherlock
  module AST
    class BinaryOperator < Expression
      def initialize(left_expression, right_expression)
        @left_expression, @right_expression = left_expression, right_expression
      end

      attr_reader :left_expression, :right_expression

      def size
        1 + @left_expression.size + @right_expression.size
      end

      def operators
        Set[self.class.bv_keyword] +
          @left_expression.operators + @right_expression.operators
      end

      def to_s
        "(#{self.class.bv_keyword} #{@left_expression} #{@right_expression})"
      end
    end
  end
end
