require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class AndOperator < BinaryOperator

      bv_keyword "and"

      def evaluate(context)
        @left_expression.evaluate(context) & @right_expression.evaluate(context)
      end
    end
  end
end
