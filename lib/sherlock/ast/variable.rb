require "set"
require_relative "expression"

module Sherlock
  module AST
    class Variable < Expression
      def initialize(name)
        @name = name
      end

      attr_reader :name
      
      def size
        1
      end

      def operators
        Set[ ]
      end

      def evaluate(context)
        context[@name]
      end

      def to_s
        @name
      end
    end
  end
end
