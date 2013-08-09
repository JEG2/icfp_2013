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
    end
  end
end
