require "set"
require_relative "binary_operator"

module Sherlock
  module AST
    class XorOperator < BinaryOperator

      bv_keyword "xor"
      
    end
  end
end
