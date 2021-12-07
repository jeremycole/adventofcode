input_file = ARGV.shift
positions = File.open(input_file).readline.split(",").map(&:to_i)

part_1_answer =
  Range.new(*positions.minmax)
       .map { |position| [position, positions.map { |p| (p - position).abs }.sum] }
       .min_by { |_, c| c }

puts "Part 1 answer: #{part_1_answer.inspect}"

part_2_answer =
  Range.new(*positions.minmax)
       .map { |position| [position, positions.map { |p| (0..(p - position).abs).sum }.sum] }
       .min_by { |_, c| c }

puts "Part 2 answer: #{part_2_answer.inspect}"
