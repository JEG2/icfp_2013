require "set"
require_relative "unary_operator"

module Sherlock
  module AST
    class ShiftLeftOne < UnaryOperator

      bv_keyword "shl1"

      def evaluate(context)
        (@expression.evaluate(context) << 1) & API::MAX_VECTOR
      end
    end
  end
end
