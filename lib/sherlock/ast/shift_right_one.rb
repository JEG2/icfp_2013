require "set"
require_relative "unary_operator"

module Sherlock
  module AST
    class ShiftRightOne < UnaryOperator

      bv_keyword "shr1"
      
      def evaluate(context)
        @expression.evaluate(context) >> 1
      end
    end
  end
end
