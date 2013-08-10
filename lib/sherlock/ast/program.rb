require "set"

module Sherlock
  module AST
    class Program
      def initialize(variable, expression)
        @variable, @expression = variable, expression
      end

      attr_reader :variable, :expression

      def size
        1 + @expression.size
      end

      def operators
        Set[] + @expression.operators
      end

      def evaluate(context)
        @expression.evaluate(context)
      end

      def run(input)
        evaluate({ @variable.name => input })
      end

      def to_s
        "(lambda (#{@variable}) #{@expression})"
      end
    end
  end
end
