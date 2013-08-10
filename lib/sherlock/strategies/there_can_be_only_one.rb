module Sherlock
  module Strategies
    class ThereCanBeOnlyOne
      SAFE_OPERATORS = { "not"   => AST::NotOperator,
                         "shr1"  => AST::ShiftRightOne,
                         "shr4"  => AST::ShiftRightFour,
                         "shr16" => AST::ShiftRightSixteen,
                         "shl1"  => AST::ShiftLeftOne }

      def self.can_handle?(problem)
        problem["operators"].size == 1 &&
        SAFE_OPERATORS.include?(problem["operators"].first)
      end

      def initialize(problem, api)
        @problem = problem
        @api     = api
      end

      attr_reader :problem, :api
      private     :problem, :api

      def solve(inner_value = AST::Variable.new("x"))
        operator = SAFE_OPERATORS.fetch(problem["operators"].first)
        attempt  = build_program(operator, inner_value)
        guess(attempt) do |response|
          case response["status"]
          when "win"
            puts "Solved!"
          when "mismatch"
            input, output, _ = response["values"].map { |hex| Integer(hex) }
            one              = AST::Constant.new(1)
            evaluated        = build_program(operator, one).run(input)
            puts "Guess was wrong."
            puts "           Input:  #{input}"
            puts " Expected output:  #{output}"
            puts "Output using one:  #{evaluated}"
            if evaluated == output
              solve(one)
            else
              solve(AST::Constant.new(0))
            end
          else
            abort "Guess error:  #{response['message']}"
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

      def guess(program, &on_success)
        puts "Guessing:  #{program}"
        sleep 5
        result, response = api.guess(problem["id"], program.to_s)
        if result == :success
          on_success.call(response)
        else
          abort "Guess failed:  #{result.to_s.tr('_', ' ')}"
        end
      end
    end
  end
end
