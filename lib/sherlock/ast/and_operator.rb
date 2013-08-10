require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class AndOperator < BinaryOperator

      bv_keyword "and"

    end
  end
end
