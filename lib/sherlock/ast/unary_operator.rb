require_relative "expression"

module Sherlock
  module AST
    class UnaryOperator < Expression
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression

      def size
        1 + @expression.size
      end

      def operators
        Set[self.class.bv_keyword] + @expression.operators
      end

      def to_s
        "(#{self.class.bv_keyword} #{@expression})"
      end
    end
  end
end
