module Sherlock
  module Strategies
    class ThereCanBeOnlyOne < Strategy
      SAFE_OPERATORS = { "not"   => AST::NotOperator,
                         "shr1"  => AST::ShiftRightOne,
                         "shr4"  => AST::ShiftRightFour,
                         "shr16" => AST::ShiftRightSixteen,
                         "shl1"  => AST::ShiftLeftOne }

      def self.can_handle?(problem)
        problem["operators"].size == 1 &&
        SAFE_OPERATORS.include?(problem["operators"].first)
      end

      def solve(inner_value = AST::Variable.new("x"))
        operator = SAFE_OPERATORS.fetch(problem["operators"].first)
        attempt  = build_program(operator, inner_value)
        guess(attempt) do |input, output, _|
          one       = build_program(operator, AST::Constant.new(1))
          evaluated = one.run(input)
          puts
          puts "Output using 1:  #{evaluated}"
          if evaluated == output
            one
          else
            build_program(operator, AST::Constant.new(0))
          end
        end
      end

      private

      def build_program(operator, inner_value)
        wrapped = inner_value
        (problem["size"] - 2).times do
          wrapped = operator.new(wrapped)
        end
        AST::Program.new(AST::Variable.new("x"), wrapped)
      end
    end
  end
end
