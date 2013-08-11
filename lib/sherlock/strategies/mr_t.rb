module Sherlock
  module Strategies
    class MrT < Strategy
      SAFE_OPERATORS = {
        "not"   => AST::NotOperator,
        "shr1"  => AST::ShiftRightOne,
        "shr4"  => AST::ShiftRightFour,
        "shr16" => AST::ShiftRightSixteen,
        "shl1"  => AST::ShiftLeftOne,
        "and"   => AST::AndOperator,
        "or"    => AST::OrOperator,
        "xor"   => AST::XorOperator,
        "plus"  => AST::PlusOperator,
        "tfold" => AST::Fold
      }

      def self.can_handle?(problem)
        problem["operators"].size == 2 &&
          SAFE_OPERATORS.include?(problem["operators"].first) &&
          SAFE_OPERATORS.include?(problem["operators"].last) &&
          problem["operators"].include?("tfold")
      end

      def solve
        problem["operators"].delete("tfold")
        if %w[ and or xor plus ].include?(problem["operators"].first)
          programs = generate_binary_programs
        else
          programs = generate_unary_programs
        end
        programs.map! do |program|
          Sherlock::Parser.parse("(lambda (x) (fold x 0 (lambda (x y) #{program})))")
        end

        guess(programs.shift.to_s) do |input, output, _|
          programs = programs.select do |program|
            program.run(input) == output
          end

          programs.shift.to_s
        end
      end

      private

      def generate_binary_programs
        generate_programs(problem["operators"].first)
      end

      def generate_unary_programs
        generate_programs(problem["operators"].first, true)
      end

      def generate_programs(operator, unary = false)
        size      = problem["size"]
        operators = unary ? (size - 7) : (size - 8) / 2
        minimal   = unary ? "(#{operator} e)" : "(#{operator} e e)"
        options   = [minimal]

        operators.times do
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
            next_options << prev_option.sub("e", "y")
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
