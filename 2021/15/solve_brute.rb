# This brute forces the pathfinding and only works on the sample.

class Cavern
  ALLOWED_MOVES = [
    #[-1, -1],
    #[-1, 0], # left
    #[-1, +1],
    [0, +1],
    #[+1, +1],
    [+1, 0],
    #[+1, -1],
    #[0, -1],
  ]

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

class Point
  attr_accessor :cavern
  attr_reader :x
  attr_reader :y
  attr_reader :risk

  def initialize(x, y, risk)
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

  def safest_forward_move
    allowed_moves.sort_by(&:risk).first(1)
  end
end

input_file = ARGV.shift
risk_levels = File.open(input_file).each_line.map { |line| line.chomp.split("").map(&:to_i) }

points = risk_levels.each_with_index.map { |row, y| row.each_with_index.map { |risk, x| Point.new(x, y, risk) } }

cavern = Cavern.new(points)

puts cavern


def path_risk(path)
  path.sum(&:risk)-path.first.risk
end

n = 0
path = cavern.each_path.min_by { |path| n += 1; puts n if (n%1000).zero?; path_risk(path) }

puts "Best path: #{path.map(&:to_s).join(" -> ")}"
puts "Path risk: #{path_risk(path)}"