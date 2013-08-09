module Sherlock
  module AST
    class Variable
      def initialize(name)
        @name = name
      end

      attr_reader :name
    end
  end
end
