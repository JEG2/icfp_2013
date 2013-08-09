require "strscan"

module Sherlock
  class Lexer
    class Token
      def initialize(type, content)
        @type    = type
        @content = content
      end

      attr_reader :type, :content

      def ==(other_token)
        type == other_token.type && content == other_token.content
      end
    end

    def initialize(program)
      @program = StringScanner.new(program)
    end

    attr_reader :program
    private     :program

    def next
      discard_whitespace
      paren ||
      keyword ||
      constant ||
      unary ||
      binary ||
      variable
    end

    private

    def discard_whitespace
      program.scan(/\s+/)
    end

    def paren
      token(/(?:\(|\))/, :paren)
    end

    def keyword
      token(/\b(?:lambda|if0|fold)\b/, :keyword)
    end
    
    def constant
      token(/\b(?:0|1)\b/, :constant)
    end

    def unary
      token(/\b(?:not|shl1|shr1|shr4|shr16)\b/, :unary)
    end

    def binary
      token(/\b(?:and|or|xor|plus)\b/, :binary)
    end

    def variable
      token(/\b[a-z][a-z_0-9]*\b/, :variable)
    end

    def token(regex, type)
      if program.scan(regex)
        Token.new(type, program.matched)
      end
    end
  end
end
