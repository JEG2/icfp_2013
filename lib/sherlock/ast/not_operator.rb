require "set"
require_relative "unary_operator"

module Sherlock
  module AST
    class NotOperator < UnaryOperator
      
      bv_keyword "not"
      
      def evaluate(context)
        @expression.evaluate(context) ^ API::MAX_VECTOR
      end
    end
  end
end
