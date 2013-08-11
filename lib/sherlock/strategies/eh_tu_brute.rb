require "pp"

module Sherlock
  module Strategies
    class EhTuBrute < Strategy
      SAFE_OPERATORS = %w[not shl1 shr1 shr4 shr16 and or xor plus]

      def self.can_handle?(problem)
        size = ENV["BRUTE_FORCE_SIZE"].to_i
        size > 0                                                       &&
        problem["size"] == size                                        &&
        problem["operators"].all? { |op| SAFE_OPERATORS.include?(op) } &&
        !problem.include?("solved")
      end

      def solve
        programs = generate_all_possible_programs
        guess(programs.shift.to_s) { |input, output, _|
          programs = programs.select { |program|
            program.run(input) == output
          }

          programs.shift.to_s
        }
      end

      private

      def generate_all_possible_programs
        programs = generate_all_possible_operators
        programs = generate_all_possible_orderings(programs)
        programs = generate_all_possible_bv_syntax(programs)
        programs = generate_all_possible_terminators(programs)
        generate_all_possible_asts(programs)
      end

      def generate_all_possible_operators
        max_size     = problem["size"] - 2
        operators    = problem["operators"].map { |op| op.sub(/\At/, "") }
        extras       = operators * problem["size"]
        combinations = (operators.size..max_size).flat_map { |n|
          extras.combination(n).reject { |mix|
            operators.any? { |op| !mix.include?(op) } ||
            mix.count("fold") > 1                     ||
            count_operators(*mix) != max_size
          }.uniq
        }
      end

      def count_operators(*operators)
        operators.inject(0) { |total, op|
          total += if %w[not shl1 shr1 shr4 shr16].include?(op)
                     1
                   elsif %w[and or xor plus].include?(op)
                     2
                   elsif op == "if0"
                     3
                   elsif op == "fold"
                     4
                   else
                     fail "Unknown operator:  #{op}"
                   end
        }
      end

      def generate_all_possible_orderings(operators)
        operators.flat_map { |mix|
          mix.permutation(mix.size).to_a
        }.uniq
      end

      def generate_all_possible_bv_syntax(mixes)
        mixes.flat_map { |mix|
          build_bv_syntax(mix)
        }.uniq
      end

      def build_bv_syntax(mix, program = "(lambda (x) e)", results = [ ])
        op   = mix.first
        rest = mix[1..-1]

        programs = [ ]
        for_each_e(program) do |i|
          next_program       = program.dup
          next_program[i, 1] = minimal_syntax(op)
          programs          << next_program
        end

        if !rest.empty?
          programs.each do |new_program|
            build_bv_syntax(rest, new_program, results)
          end
          results
        else
          results.concat(programs)
        end
      end

      def for_each_e(expression, &block)
        i = 0
        while (j = expression.index("e", i))
          block.call(j)
          i = j + 1
        end
      end

      def minimal_syntax(op)
        if %w[not shl1 shr1 shr4 shr16].include?(op)
          "(#{op} e)"
        elsif %w[and or xor plus].include?(op)
          "(#{op} e e)"
        elsif op == "if0"
          "(if0 e e e)"
        elsif op == "fold"
          "(fold e e (lambda (x y) e))"
        else
          fail "Unknown operator:  #{op}"
        end
      end

      def generate_all_possible_terminators(expressions)
        # if problem["operators"].include?("fold")
          
        # end
        expressions.flat_map { |expression|
          expansions = [expression]
          while expressions.first.include?("e")
            expressions = expressions.flat_map { |expression|
              vars = %w[x 0 1]
              vars.map { |var| expression.sub("e", var) }
            }
          end
          expressions
        }.uniq
      end

      def generate_all_possible_asts(programs)
        programs.map { |program|
          Parser.parse(program)
        }
      end
    end
  end
end
