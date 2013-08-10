require "set"

module Sherlock
  module AST
    class ShiftRightFour
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression

      def size
        1 + @expression.size
      end

      def operators
        Set["shr4"] + @expression.operators
      end

      def evaluate(context)
        @expression.evaluate(context) >> 4
      end

      def to_s
        "(shr4 #{@expression})"
      end
    end
  end
end
