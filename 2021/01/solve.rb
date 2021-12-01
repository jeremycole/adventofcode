#!/usr/bin/env ruby

depths = File.open(ARGV.first).each_line.map(&:to_i)

[1, 3].each do |window_size|
  increases = depths.each_cons(window_size).map(&:sum).each_cons(2).count { |a, b| b > a }
  puts "Increasing depths with window of #{window_size}: #{increases}"
end
