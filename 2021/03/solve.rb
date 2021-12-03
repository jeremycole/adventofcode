def most_common_bit(report, bit)
  report
    .map { |a| a[bit] }
    .each_with_object(Hash.new(0)) { |n, h| h[n] += 1 }
    .max_by { |k, v| [v, k] }
    .first
end

def least_common_bit(report, bit)
  report
    .map { |a| a[bit] }
    .each_with_object(Hash.new(0)) { |n, h| h[n] += 1 }
    .min_by { |k, v| [v, k] }
    .first
end

input_file = ARGV.shift
report = File.open(input_file).each_line.map(&:chomp)

bit_length = report[0].length
most_common_str = bit_length.times.map { |i| most_common_bit(report, i) }.join
most_common_val = most_common_str.to_i(2)

least_common_val = most_common_val ^ (2**bit_length-1)
least_common_str = format("%0#{bit_length}b", least_common_val)

puts "most common: #{most_common_str}, least common: #{least_common_str}"
puts "part 1 answer: #{most_common_val * least_common_val}"

most_common_found = report.dup
bit_length.times.each do |i|
  b = most_common_bit(most_common_found, i)
  most_common_found.select! { |v| v[i] == b }
  break if most_common_found.size == 1
end

least_common_found = report.dup
bit_length.times.each do |i|
  b = least_common_bit(least_common_found, i)
  least_common_found.select! { |v| v[i] == b }
  break if least_common_found.size == 1
end

puts "most common: #{most_common_found}, least common: #{least_common_found}"
puts "part 2 answer: #{most_common_found.first.to_i(2) * least_common_found.first.to_i(2)}"