module Sherlock
  module AST
    class Expression
      def self.bv_keyword(keyword = nil)
        @bv_keyword = keyword if keyword
        @bv_keyword
      end
    end
  end
end
