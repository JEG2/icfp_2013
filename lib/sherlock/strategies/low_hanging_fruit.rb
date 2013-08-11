module Sherlock
  module Strategies
    class LowHangingFruit < Strategy
      SAFE_OPERATORS = %w[ not shl1 shr1 shr4 shr16 tfold ]

      def self.can_handle?(problem)
        problem["operators"].all? do |op|
          SAFE_OPERATORS.include?(op)
        end
      end

      def solve
        size  = 2
        tfold = false
        if problem["operators"].delete("tfold")
          tfold = true
          size += 4
        end
        base_size = size

        counts = [ ]
        build_counts(problem["operators"], size, counts, base_size)

        orderings = counts.flat_map do |count|
          count.permutation(count.size).to_a
        end

        expressions = orderings.map do |order|
          order.reverse.inject("e") do |inner, op|
            "(#{op} #{inner})"
          end
        end.uniq

        next_expressions = [ ]
        expressions.each do |prev_option|
          next_expressions << prev_option.sub("e", "x")
          next_expressions << prev_option.sub("e", "1")
          next_expressions << prev_option.sub("e", "0")
          next_expressions << prev_option.sub("e", "y") if tfold
        end
        
        expressions = next_expressions

        programs = expressions.map do |expression|
          expression = "(fold x 0 (lambda (x y) #{expression}))" if tfold
          Sherlock::Parser.parse("(lambda (x) #{expression})")
        end

        guess(programs.shift.to_s) do |input, output, _|
          programs = programs.select do |program|
            program.run(input) == output
          end

          programs.shift.to_s
        end

      end

      private

      def build_counts(ops, size, choices, base_size, mix = [])
        min_count = (size + (ops.size - 1))
        (problem["size"] - min_count).downto(1) do |count|
          rest    = ops[1..-1]
          new_mix = mix + [ops.first] * count
          if rest.empty?
            choices << new_mix if new_mix.size + base_size == problem["size"]
          else
            build_counts(rest, size + count, choices, base_size, new_mix)
          end
        end
      end
    end
  end
end
