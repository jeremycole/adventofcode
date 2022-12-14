#!/usr/bin/env ruby
# frozen_string_literal: true

File.open(ARGV.first).each_line do |line|
  match, start = line.split("").each_cons(4).each_with_index.find { |a, i| a.uniq.size == 4 }
  puts "Found start of packet marker at #{start+4}"

  match, start = line.split("").each_cons(14).each_with_index.find { |a, i| a.uniq.size == 14 }
  puts "Found start of message marker at #{start+14}"
end