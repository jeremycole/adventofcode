require "gastar"

class Cavern
  ALLOWED_MOVES = [
    [-1, 0],
    [0, +1],
    [+1, 0],
    [0, -1],
  ]

  def self.path_risk(path)
    path.sum(&:risk)-path.first.risk
  end

  attr_reader :grid
  attr_reader :rows
  attr_reader :cols

  def initialize(grid)
    @grid = grid
    @rows = grid.size
    @cols = grid.first.size

    each_point { |p| p.cavern = self }
  end

  def to_s
    grid.map { |row| row.map { |point| point.risk }.join }.join("\n")
  end

  def x_range
    (0...@cols)
  end

  def y_range
    (0...@rows)
  end

  def each_point
    return enum_for(:each_point) unless block_given?

    grid.each do |row|
      row.each do |point|
        yield point
      end
    end

    nil
  end

  def point_at(x, y)
    return unless x_range.cover?(x) && y_range.cover?(y)

    @grid[y][x]
  end

  def start
    point_at(0, 0)
  end

  def finish
    point_at(x_range.max, y_range.max)
  end

  def allowed_moves(point)
    ALLOWED_MOVES.map { |ax, ay| point_at(point.x + ax, point.y + ay) }.compact
  end

  def find_path(point=point_at(0, 0), path=[], proc=nil, &block)
    proc ||= block
    path.push(point)
    #this_path = path + [point]

    moves = point.safest_forward_move
    proc.call(path.dup) if moves.none?

    moves.each do |next_point|
      find_path(next_point, path, proc)
    end

    path.pop
  end

  def each_path(point=point_at(0, 0), path=[])
    return enum_for(:each_path) unless block_given?

    find_path do |path|
      yield path
    end

    nil
  end
end

class Point < AStarNode
  attr_accessor :cavern
  attr_reader :x
  attr_reader :y
  attr_reader :risk

  def initialize(x, y, risk)
    super()

    @cavern = nil
    @x = x
    @y = y
    @risk = risk
  end

  def to_s
    "#{x}, #{y} (#{risk})"
  end

  def allowed_moves
    cavern.allowed_moves(self)
  end

  def move_cost(other)
    other.risk
  end
end


class CavernPathSearch < AStar
  def initialize(cavern, maximize_cost = nil)
    graph = cavern.each_point.map { |point| [point, point.allowed_moves] }.to_h

    super(graph)
  end

  def heuristic(node, start, goal)
    (goal.x - node.x) + (goal.y - node.y)
  end
end

input_file = ARGV.shift
small_cavern_risk_levels = File.open(input_file).each_line.map { |line| line.chomp.split("").map(&:to_i) }

small_cavern_points = small_cavern_risk_levels.each_with_index.map { |row, y| row.each_with_index.map { |risk, x| Point.new(x, y, risk) } }

small_cavern = Cavern.new(small_cavern_points)
#puts small_cavern
small_cavern_path_search = CavernPathSearch.new(small_cavern)
small_cavern_path = small_cavern_path_search.search(small_cavern.start, small_cavern.finish)

puts "Answer to part 1: #{Cavern.path_risk(small_cavern_path)}"

def wrap_risk(n)
  ((n-1) % 9) + 1
end

big_cavern_risk_levels = (0..4).flat_map { |i| small_cavern_risk_levels.map { |row| (i..(i+4)).flat_map { |j| row.map { |risk| wrap_risk(risk+j) } } } }

big_cavern_points = big_cavern_risk_levels.each_with_index.map { |row, y| row.each_with_index.map { |risk, x| Point.new(x, y, risk)  } }

big_cavern = Cavern.new(big_cavern_points)
#puts big_cavern
big_cavern_path_search = CavernPathSearch.new(big_cavern)
big_cavern_path = big_cavern_path_search.search(big_cavern.start, big_cavern.finish)

puts "Answer to part 2: #{Cavern.path_risk(big_cavern_path)}"
