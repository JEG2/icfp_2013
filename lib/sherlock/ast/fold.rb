require "set"
require_relative "expression"

module Sherlock
  module AST
    class Fold < Expression
      def initialize(folded_over, initializer, byte, accumulator, expression)
        @folded_over = folded_over
        @initializer = initializer
        @byte        = byte
        @accumulator = accumulator
        @expression  = expression
      end

      attr_reader :folded_over, :initializer, :byte, :accumulator, :expression

      bv_keyword "fold"

      def size
        2 + @folded_over.size + @initializer.size + @expression.size
      end

      def operators
        Set[self.class.bv_keyword] +
          @folded_over.operators +
          @initializer.operators +
          @expression.operators
      end

      def to_s
        "(#{self.class.bv_keyword} #{@folded_over} #{initializer} (lambda (#{@byte} #{@accumulator}) #{@expression}))"
      end
    end
  end
end
