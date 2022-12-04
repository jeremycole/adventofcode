# frozen_string_literal: true

input_file = ARGV.first
ranges = File.open(input_file).each_line.map do |line|
  line.chomp.split(",").map do |range|
    Range.new(*range.split("-").map(&:to_i))
  end
end

puts ranges.count { |a, b| a.cover?(b) || b.cover?(a) }
puts ranges.count { |a, b| a.any?(b) || b.any?(a) }