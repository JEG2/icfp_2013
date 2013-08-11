module Sherlock
  module Strategies
    class IfsAndShifts < Strategy
      BINARY_OPERATORS = %w[ and or xor plus ]
      UNARY_OPERATORS  = %w[ not shl1 shr1 shr4 shr16 ]

      def self.can_handle?(problem)
        problem = Marshal.load(Marshal.dump(problem))
        problem["operators"].size == 2 &&
          problem["operators"].include?("if0") &&
        ((problem["size"] == 6 && unary_operators?(problem)) ||
         (problem["size"] == 7 && binary_operators?(problem)))
      end

      def self.unary_operators?(problem)
        problem["operators"].delete("if0")
        UNARY_OPERATORS.include?(problem["operators"].first)
      end

      def self.binary_operators?(problem)
        problem["operators"].delete("if0")
        BINARY_OPERATORS.include?(problem["operators"].first)
      end

      def solve
        problem["operators"].delete("if0")
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

      private

      def solve_binary
        operator = problem["operators"].first
        orders = [ "(#{operator} e e)", "e", "e" ].permutation(3).to_a.uniq.map { |order|
          "#{order.join(" ")}"}
        array = %w[ x 1 0 ].flat_map { |x| [x] * 4}.permutation(4).to_a.uniq
        permutations = orders.flat_map { |order| array.map { |vars| vars.inject(order) { |program, var| program.sub("e", var)}}}.uniq
        programs = permutations.map { |expression|
          Sherlock::Parser.parse("(lambda (x) (if0 #{expression}))") }
      end

      def solve_unary
        operator = problem["operators"].first
        orders = [ "(#{operator} e)", "e", "e" ].permutation(3).to_a.uniq.map { |order|
          "#{order.join(" ")}"}
        array = %w[ x 1 0 ].flat_map { |x| [x] * 3}.permutation(3).to_a.uniq
        permutations = orders.flat_map { |order| array.map { |vars| vars.inject(order) { |program, var| program.sub("e", var)}}}.uniq
        programs = permutations.map { |expression|
          Sherlock::Parser.parse("(lambda (x) (if0 #{expression}))") }
      end
    end
  end
end

