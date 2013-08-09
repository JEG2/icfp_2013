require "bundler"
Bundler.setup

require_relative "sherlock/api"
require_relative "sherlock/lexer"
require_relative "sherlock/ast/variable"
require_relative "sherlock/ast/not_operator"
require_relative "sherlock/parser"
