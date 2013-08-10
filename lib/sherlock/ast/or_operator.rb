require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class OrOperator < BinaryOperator

      bv_keyword "or"

      def evaluate(context)
        @left_expression.evaluate(context) | @right_expression.evaluate(context)
      end
    end
  end
end
