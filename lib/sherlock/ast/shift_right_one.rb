require "set"

module Sherlock
  module AST
    class ShiftRightOne
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression
      
      def size
        1 + @expression.size
      end

      def operators
        Set["shr1"] + @expression.operators
      end

      def evaluate(context)
        @expression.evaluate(context) >> 1
      end
    end
  end
end
