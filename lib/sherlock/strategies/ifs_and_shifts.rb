module Sherlock
  module Strategies
    class IfsAndShifts < Strategy
      SAFE_OPERATORS = %w[ not shl1 shr1 shr4 shr16 and or xor plus if0 ]

      def self.can_handle?(problem)
        problem["operators"].size == 2 &&
          problem["operators"].include?("if0") &&
          problem["size"] == 6 && problem["operators"].include?("")

      end

      def solve
        orders = [ "(plus e e)", "e", "e" ].permutation(3).to_a.uniq.map { |order|
          "#{order.join(" ")}"}
        array = %w[ x 1 0 ].flat_map { |x| [x] * 4}.permutation(4).to_a.uniq
        permutations = orders.flat_map { |order| array.map { |vars| vars.inject(order) { |program, var| program.sub("e", var)}}}
        
        if problem["size"] == 7
          programs = solve_binary
        else
          programs = solve_unary
        end

        guess(programs.shift.to_s) do |input, output, _|
          programs = programs.select do |program|
            program.run(input) == output
          end

          programs.shift.to_s
        end
      end

      def solve_binary(permutations)
        possible_programs = permutations.map do |permutation|
          "(lambda (x) (if0 )"
        end

        programs = possible_programs.map do |program|
          Sherlock::Parser.parse(program)
        end
      end
    end
  end
end
