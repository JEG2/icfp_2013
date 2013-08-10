require "set"

module Sherlock
  module AST
    class Constant
      def initialize(value)
        @value = value
      end

      attr_reader :value

      def size
        1
      end

      def operators
        Set[ ]
      end

      def evaluate(context)
        @value
      end
    end
  end
end