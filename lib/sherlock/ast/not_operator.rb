module Sherlock
  module AST
    class NotOperator
      def initialize(expression)
        @expression = expression
      end

      attr_reader :expression
    end
  end
end
