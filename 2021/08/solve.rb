#!/usr/bin/env ruby

Data = Struct.new(:signals, :outputs)

class Resolver
  attr_reader :signals

  def initialize(signals)
    @signals = signals
  end

  def build_lookup_by_digit
    p = {}

    p[1] = signals.find { |s| s.size == 2 }
    p[4] = signals.find { |s| s.size == 4 }
    p[7] = signals.find { |s| s.size == 3 }
    p[8] = signals.find { |s| s.size == 7 }

    s6 = signals.select { |s| s.size == 6 }
    p[9] = s6.find { |s| (s & p[4]) == p[4] }
    p[0] = s6.find { |s| !p.values.include?(s) && (s & p[1]) == p[1] }
    p[6] = s6.find { |s| !p.values.include?(s) }

    s5 = signals.select { |s| s.size == 5 }
    p[3] = s5.find { |s| (s & p[1]) == p[1] }
    p[5] = s5.find { |s| !p.values.include?(s) && (s & (p[4] - p[1])).size == 2 }
    p[2] = s5.find { |s| !p.values.include?(s) }

    p
  end

  def lookup_by_digit
    @lookup_by_digit ||= build_lookup_by_digit
  end

  def lookup_by_pattern
    @lookup_by_pattern ||= lookup_by_digit.invert
  end

  def resolve(pattern)
    lookup_by_pattern[pattern]
  end
end

input_file = ARGV.shift
data = File.open(input_file)
           .each_line
           .map { |l| l.chomp.split(" | ") }
           .map { |a| a.map { |b| b.split(" ").map { |x| x.split("").sort } } }
           .map { |a| Data.new(*a) }

summary = data.flat_map(&:outputs).map(&:size).tally

answer_part_1 = [2, 3, 4, 7].map { |l| summary[l] || 0 }.sum
puts "Answer for part 1: #{answer_part_1}"

solution = data.map do |d|
  resolver = Resolver.new(d.signals)
  d.outputs.map { |pattern| resolver.resolve(pattern) }
end

answer_part_2 = solution.map { |x| x.map(&:to_s).join.to_i }.sum
puts "Answer for part 2: #{answer_part_2}"
