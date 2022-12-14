# frozen_string_literal: true

require "forest"

trees = File.open(ARGV.first)
            .each_line
            .each_with_index
            .map { |line, y|
              line.chomp
                  .each_char
                  .each_with_index
                  .map { |h, x| Tree.new(x, y, h.to_i) }
            }

forest = Forest.new(trees)

puts forest.each_tree.count(&:visible?)

puts forest.each_tree.max_by(&:scenic_score).scenic_score