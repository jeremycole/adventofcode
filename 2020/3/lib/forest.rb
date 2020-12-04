# frozen_string_literal: true

class Forest
  attr_reader :filename

  TREE = '#'

  def initialize(filename)
    @filename = filename
    @forest = File.readlines('input.txt').map { |line| line.strip.split('') }
  end

  def width
    @width ||= @forest.first.size
  end

  def height
    @height ||= @forest.size
  end

  def tree?(x, y)
    return nil unless y < height

    @forest[y][x % width] == TREE
  end
end
