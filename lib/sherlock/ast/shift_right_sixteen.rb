require "set"
require_relative "unary_operator"

module Sherlock
  module AST
    class ShiftRightSixteen < UnaryOperator

      bv_keyword "shr16"

      def evaluate(context)
        @expression.evaluate(context) >> 16
      end
    end
  end
end
