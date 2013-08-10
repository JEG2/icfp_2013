require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class OrOperator < BinaryOperator

      bv_keyword "or"

    end
  end
end
