require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class XorOperator < BinaryOperator

      bv_keyword "xor"

      def evaluate(context)
        @left_expression.evaluate(context) ^ @right_expression.evaluate(context)
      end
    end
  end
end
