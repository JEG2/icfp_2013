require "set"
require_relative "expression"

module Sherlock
  module AST
    class Constant < Expression
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

      def to_s
        @value.to_s
      end
    end
  end
end
