# frozen_string_literal: true

require 'slope'

class Course
  attr_reader :forest, :slope

  def initialize(forest:, slope:)
    @forest = forest
    @slope = slope
  end

  def steps
    (forest.height / slope.down)
      .times
      .map { |i| i * slope.down }
      .each_with_index
      .map { |y, i| [i * slope.right, y] }
  end

  def trees
    steps.each.count { |x, y| forest.tree?(x, y) }
  end
end
