require "set"

module Sherlock
  module AST
    class Fold
      def initialize(folded_over, initializer, byte, accumulator, expression)
        @folded_over = folded_over
        @initializer = initializer
        @byte        = byte
        @accumulator = accumulator
        @expression  = expression
      end

      attr_reader :folded_over, :initializer, :byte, :accumulator, :expression

      def size
        2 + @folded_over.size + @initializer.size + @expression.size
      end

      def operators
        Set["fold"] +
          @folded_over.operators +
          @initializer.operators +
          @expression.operators
      end
    end
  end
end