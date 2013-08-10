require "set"
require_relative "unary_operator"

module Sherlock
  module AST
    class ShiftRightFour < UnaryOperator

      bv_keyword "shr4"
      
      def evaluate(context)
        @expression.evaluate(context) >> 4
      end
    end
  end
end
