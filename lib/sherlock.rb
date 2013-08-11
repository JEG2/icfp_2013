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

require_relative "sherlock/strategy"
require_relative "sherlock/strategies/there_can_be_only_one"
require_relative "sherlock/strategies/it_takes_two"
require_relative "sherlock/strategies/mr_t"
require_relative "sherlock/strategies/low_hanging_fruit"
require_relative "sherlock/strategies/what_if"
require_relative "sherlock/strategies/ifs_and_shifts"
require_relative "sherlock/strategies/eh_tu_brute"
require_relative "sherlock/solver"
