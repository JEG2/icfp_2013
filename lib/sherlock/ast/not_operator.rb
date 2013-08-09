module Sherlock
  module AST
    class NotOperator
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression

      def size
        1 + @expression.size
      end
    end
  end
end
