#!/usr/bin/env ruby

require "heightmap"

input_file = ARGV.shift
heightmap = Heightmap.new(input_file)

answer_part_1 = heightmap.each_low_point.map { |_, _, p| 1+p }.sum
puts "Answer for part 1: #{answer_part_1}"

answer_part_2 = heightmap.each_basin.map(&:size).max(3).reduce(:*)
puts "Answer for part 2: #{answer_part_2}"