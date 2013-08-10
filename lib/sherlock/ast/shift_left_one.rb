require "set"

module Sherlock
  module AST
    class ShiftLeftOne
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression
      
      def size
        1 + @expression.size
      end

      def operators
        Set["shl1"] + @expression.operators
      end

      def evaluate(context)
        (@expression.evaluate(context) << 1) & API::MAX_VECTOR
      end

      def to_s
        "(shl1 #{@expression})"
      end
    end
  end
end
