require "set"

module Sherlock
  module AST
    class Variable
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
    end
  end
end
