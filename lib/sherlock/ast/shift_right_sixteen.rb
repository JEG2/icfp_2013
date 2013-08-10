require "set"

module Sherlock
  module AST
    class ShiftRightSixteen
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression

      def size
        1 + @expression.size
      end

      def operators
        Set["shr16"] + @expression.operators
      end
    end
  end
end
