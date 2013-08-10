require "set"
require_relative "expression"

module Sherlock
  module AST
    class IfOperator < Expression
      def initialize(condition, consequence, alternative)
        @condition   = condition
        @consequence = consequence
        @alternative = alternative
      end

      bv_keyword "if0"

      attr_reader :condition, :consequence, :alternative

      def size
        1 + @condition.size + @consequence.size + @alternative.size
      end

      def operators
        Set[self.class.bv_keyword] +
          @condition.operators +
          @consequence.operators +
          @alternative.operators
      end

      def to_s
        "(#{self.class.bv_keyword} #{@condition} #{@consequence} #{@alternative})"
      end

      def evaluate(context)
        if @condition.evaluate(context).zero?
          @consequence.evaluate(context)
        else
          @alternative.evaluate(context)
        end
      end
    end
  end
end
