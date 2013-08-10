require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class PlusOperator < BinaryOperator

      bv_keyword "plus"

      def evaluate(context)
        (@left_expression.evaluate(context) + @right_expression.evaluate(context)) &
          MAX_VECTOR
      end
    end
  end
end
