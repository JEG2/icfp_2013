module Sherlock
  module AST
    class IfOperator
      def initialize(condition, consequence, alternative)
        @condition   = condition
        @consequence = consequence
        @alternative = alternative
      end

      attr_reader :condition, :consequence, :alternative

      def size
        1 + @condition.size + @consequence.size + @alternative.size
      end
    end
  end
end
