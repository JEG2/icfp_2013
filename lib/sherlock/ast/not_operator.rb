require "set"

module Sherlock
  module AST
    class NotOperator
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression

      def size
        1 + @expression.size
      end

      def operators
        Set["not"] + @expression.operators
      end

      def evaluate(context)
        @expression.evaluate(context) ^ API::MAX_VECTOR
      end

      def to_s
        "(not #{@expression})"
      end
    end
  end
end
