require "bundler"
Bundler.setup

require_relative "sherlock/api"

require_relative "sherlock/lexer"

require_relative "sherlock/ast/variable"
require_relative "sherlock/ast/not_operator"
require_relative "sherlock/ast/constant"
require_relative "sherlock/ast/shift_left_one"
require_relative "sherlock/ast/shift_right_one"
require_relative "sherlock/ast/shift_right_four"
require_relative "sherlock/ast/shift_right_sixteen"
require_relative "sherlock/ast/and_operator"
require_relative "sherlock/ast/or_operator"
require_relative "sherlock/ast/xor_operator"
require_relative "sherlock/ast/plus_operator"
require_relative "sherlock/ast/if_operator"
require_relative "sherlock/ast/fold"
require_relative "sherlock/ast/program"
require_relative "sherlock/parser"

require_relative "sherlock/strategies/there_can_be_only_one"
require_relative "sherlock/solver"
