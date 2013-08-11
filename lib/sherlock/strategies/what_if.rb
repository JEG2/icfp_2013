module Sherlock
  module Strategies
    class WhatIf < Strategy
      def self.can_handle?(problem)
        problem["size"] == 9 &&
          problem["operators"].sort == %w[ if0 tfold ]
      end

      def solve
        permutations      = %w[ 0 1 x y ].flat_map { |x| [ x ] * 3 }.permutation(3).to_a.uniq
        possible_programs = permutations.map do |permutation|
          "(lambda (x) (fold x 0 (lambda (x y) (if0 #{permutation.join(" ")}))))"
        end

        programs = possible_programs.map do |program|
          Sherlock::Parser.parse(program)
        end

        guess(programs.shift.to_s) do |input, output, _|
          programs = programs.select do |program|
            program.run(input) == output
          end

          programs.shift.to_s
        end
      end
    end
  end
end
