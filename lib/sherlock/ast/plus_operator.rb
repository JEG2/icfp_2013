require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class PlusOperator < BinaryOperator

      bv_keyword "plus"

    end
  end
end
