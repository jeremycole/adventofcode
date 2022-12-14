# frozen_string_literal: true

class Tree
  attr_reader :x
  attr_reader :y
  attr_reader :height
  attr_reader :forest

  def initialize(x, y, height)
    @x = x
    @y = y
    @height = height
  end

  def to_s
    "[#{x}, #{y}, #{height}]"
  end

  def inspect
    to_s
  end

  def set_forest(forest)
    @forest = forest
  end

  def visible?
    forest.visible?(self)
  end

  def scenic_score
    forest.scenic_score(self)
  end
end
