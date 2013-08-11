require "pp"

module Sherlock
  module Strategies
    class ItTakesTwo < Strategy
      SAFE_OPERATORS = { "and"   => AST::AndOperator,
        "or"    => AST::OrOperator,
        "xor"  => AST::XorOperator,
        "plus" => AST::PlusOperator }

      def self.can_handle?(problem)
        problem["operators"].size == 1 &&
          SAFE_OPERATORS.include?(problem["operators"].first)
      end

      def solve
        programs = generate_programs(problem["operators"].first)
        programs.map! do |program|
          Sherlock::Parser.parse("(lambda (x) #{program})")
        end

        guess(programs.shift.to_s) do |input, output, _|
          programs = programs.select do |program|
            program.run(input) == output
          end

          programs.shift.to_s
        end
      end

      private

      def generate_programs(operator)
        size      = problem["size"]
        operators = (size - 4) / 2 + 1
        minimal   = "(#{operator} e e)"
        options   = [minimal]

        (operators - 1).times do
          next_options = [ ]
          while (prev_option = options.shift)
            i = 0
            while (j = prev_option.index("e", i))
              next_option       = prev_option.dup
              next_option[j, 1] = minimal
              next_options << next_option
              i = j + 1
            end
          end
          options = next_options.uniq
        end

        while options.first.include?("e")
          next_options = [ ]
          options.each do |prev_option|
            next_options << prev_option.sub("e", "x")
            next_options << prev_option.sub("e", "1")
            next_options << prev_option.sub("e", "0")
          end
          options = next_options
        end
        options
      end
    end
  end
end
