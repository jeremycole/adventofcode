class Dot
  attr_reader :x
  attr_reader :y

  def initialize(paper, x, y)
    @x = x
    @y = y
  end
end

class Paper
  attr_reader :dots
  attr_reader :rows
  attr_reader :cols
  attr_reader :grid

  def initialize
    @dots = []
    @rows = 0
    @cols = 0
    @grid = {}
  end

  def resize(x, y)
    @cols = [@cols, x+1].max
    @rows = [@rows, y+1].max
  end

  def x_range
    (0...@cols)
  end

  def y_range
    (0...@rows)
  end

  def dot(x, y)
    @grid[[x, y]]
  end

  def add_dot(x, y)
    return self if dot(x, y)

    resize(x, y)
    dot = Dot.new(self, x, y)
    dots.push(dot)
    @grid[[x, y]] = dot

    self
  end

  def fold_x(new_paper, x)
    dots.each do |dot|
      new_paper.add_dot(dot.x < x ? dot.x : x - (dot.x - x), dot.y)
    end
  end

  def fold_y(new_paper, y)
    dots.each do |dot|
      new_paper.add_dot(dot.x, dot.y < y ? dot.y : y - (dot.y - y))
    end
  end

  def fold(along)
    new_paper = Paper.new

    case along.axis
    when :x
      fold_x(new_paper, along.value)
    when :y
      fold_y(new_paper, along.value)
    end

    new_paper
  end

  def dump
    y_range.map { |y| x_range.map { |x| dot(x, y) ? "#" : "." }.join }.join("\n")
  end
end

class Fold
  attr_reader :axis
  attr_reader :value

  def initialize(axis, value)
    @axis = axis
    @value = value
  end

  def to_s
    "fold along #{axis}=#{value}"
  end
end

paper = Paper.new
folds = []
input_file = ARGV.shift
File.open(input_file).each_line do |line|
  line = line.chomp

  if /\A\d+[,]\d+\z/.match(line)
    x, y = line.split(",").map(&:to_i)
    paper.add_dot(x, y)
  elsif (m = /\Afold along ([xy])=(\d+)/.match(line))
    folds.push(Fold.new(m[1].to_sym, m[2].to_i))
  end
end

#pp paper.dots
#pp paper

#puts paper.dump
#pp folds


folds.each do |fold|
  paper = paper.fold(fold)
  puts paper.dots.size
end

puts paper.dump

#pp paper_folded.dots
#puts paper_folded.dump

