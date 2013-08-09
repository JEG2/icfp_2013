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
      open_paren ||
      lambda
    end

    private

    def open_paren
      token(/\(/, :paren)
    end

    def lambda
      token(/\blambda\b/, :keyword)
    end

    def token(regex, type)
      if program.scan(regex)
        Token.new(type, program.matched)
      end
    end
  end
end
