size      = 8
operators = (size - 4) / 2 + 1

minimal = "(plus e e)"

# generate tree
options = [minimal]
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

# generate x, 1, and 0 variations
while options.first.include?("e")
  next_options = [ ]
  options.each do |prev_option|
    next_options << prev_option.sub("e", "x")
    next_options << prev_option.sub("e", "1")
    next_options << prev_option.sub("e", "0")
  end
  options = next_options
end

Dir.chdir "../Documents/icfp_2013"
require_relative "../Documents/icfp_2013/lib/sherlock"

inputs = [ 0,
           1,
           Sherlock::AST::Expression::MAX_VECTOR,
           Sherlock::AST::Expression::MAX_VECTOR - 1,
           0x0123456789ABCDEF,
           0x1122334455667788,
           0xFFFFFFFF00000000,
           0x00000000FFFFFFFF,
           0x00000000FFFF0000,
           0x0000FFFF00000000 ]
until inputs.size == 256
  inputs << rand(0..Sherlock::AST::Expression::MAX_VECTOR)
  inputs.uniq!
end
inputs.sort!

results = [ ]
options.each do |bv|
  puts bv
  program = Sherlock::Parser.parse("(lambda (x) #{bv})")
  results << [ program,
               bv.scan(/\b[x01]\b/).sort.join,
               inputs.map { |input| program.run(input) } ]
end

results.each do |answer|
  results.each do |comparison|
    next unless answer[1] == comparison[1]

    if answer.last != comparison.last
      puts
      puts answer.first
      puts comparison.first
      puts answer.last.find.with_index { |n, i| n != comparison.last[i] }
      exit
    end
  end
end
puts "All match!"
