# frozen_string_literal: true

require "tree"

class Forest
  attr_reader :trees
  attr_reader :min_x
  attr_reader :max_x
  attr_reader :min_y
  attr_reader :max_y

  def initialize(trees)
    @trees = trees
    @min_x = 0
    @max_x = trees.first.size
    @min_y = 0
    @max_y = trees.size

    each_tree { |tree| tree.set_forest(self) }
  end

  def tree(x, y)
    trees[y][x]
  end

  def each_tree
    return enum_for(:each_tree) unless block_given?

    trees.each do |row|
      row.each do |tree|
        yield tree
      end
    end

    nil
  end

  def trees_to_edge(tree, direction)
    case direction
    when :left
      (min_x...tree.x).map { |x| tree(x, tree.y) }.reverse
    when :right
      ((tree.x+1)...max_x).map { |x| tree(x, tree.y) }
    when :up
      (min_y...tree.y).map { |y| tree(tree.x, y) }.reverse
    when :down
      ((tree.y+1)...max_y).map { |y| tree(tree.x, y) }
    end
  end

  def trees_to_all_edges(tree)
    [:left, :right, :up, :down].flat_map { |direction| trees_to_edge(tree, direction) }
  end

  def visible_from_edge?(tree, direction)
    trees_to_edge(tree, direction).all? { |x| x.height < tree.height }
  end

  def viewing_distance(tree, direction)
    trees_to_edge(tree, direction).slice_when { |neighbor| neighbor.height >= tree.height }.first&.size || 0
  end

  def visible?(tree)
    [:left, :right, :up, :down].any? { |direction| visible_from_edge?(tree, direction) }
  end

  def scenic_score(tree)
    [:left, :right, :up, :down].map { |direction| viewing_distance(tree, direction) }.reduce(:*)
  end
end
