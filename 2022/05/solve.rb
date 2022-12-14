#!/usr/bin/env ruby
# frozen_string_literal: true

input_data = File.read(ARGV.first).split("\n\n")
stacks_data = input_data.shift.split(/\n/)
move_data = input_data.shift.split(/\n/)

stack_names = stacks_data.pop
stacks = stack_names.each_char
                    .each_with_index
                    .select { |name, _| name != " " }
                    .to_h { |name, index|
                      [
                        name,
                        stacks_data.map(&:each_char)
                                   .map(&:to_a)
                                   .map { |a| a[index] }
                                   .reject { |v| [" ", nil].include?(v) }
                                   .reverse
                      ]
                    }

move_data.each do |move|
  matches = /move (\d+) from (\d+) to (\d+)/.match(move)
  raise unless matches

  count = matches[1].to_i
  from = matches[2]
  to = matches[3]

  # part 1
  # count.times { stacks[to].push(stacks[from].pop) }

  # part 2
  stacks[from].pop(count).each { |x| stacks[to].push(x) }
end

puts stacks.values.map(&:last).join