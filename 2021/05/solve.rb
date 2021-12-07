class Point < Struct.new(:x, :y)
  def to_s
    "#{x},#{y}"
  end
end

class Line
  attr_reader :a, :b

  def self.parse(definition)
    new(*definition.split(" -> ").map { |p| Point.new(*p.split(",").map(&:to_i)) })
  end

  def initialize(a, b)
    @a = a
    @b = b
  end

  def horizontal?
    a.y == b.y
  end

  def vertical?
    a.x == b.x
  end

  def diagonal?
    a.x != b.x && a.y != b.y
  end

  def length
    1 + [(a.x-b.x).abs, (a.y-b.y).abs].max
  end

  def ab_enumerator(a, b)
    if b > a
      a.upto(b)
    elsif a > b
      a.downto(b)
    else
      [a] * length
    end
  end

  def each_x
    return enum_for(:each_x) unless block_given?

    ab_enumerator(a.x, b.x).each { |n| yield n }
  end

  def each_y
    return enum_for(:each_y) unless block_given?

    ab_enumerator(a.y, b.y).each { |n| yield n }
  end

  def each_point
    return enum_for(:each_point) unless block_given?

    each_x.zip(each_y).each do |x, y|
      yield Point.new(x, y)
    end

    nil
  end

  def orientation
    [
      horizontal? ? "horizontal" : nil,
      vertical? ? "vertical" : nil,
      diagonal? ? "diagonal" : nil,
    ].compact.join
  end

  def to_s
    "#{a} -> #{b} (#{orientation}, length #{length})"
  end
end

class Field
  attr_reader :lines
  attr_reader :field
  attr_reader :dim
  attr_reader :y

  def initialize(lines)
    @lines = lines
    @dim = Point.new(
      lines.map { |l| [l.a.x, l.b.x].max }.max,
      lines.map { |l| [l.a.y, l.b.y].max }.max
    )
    @field = (0..@dim.y).map { (0..@dim.x).map { 0 } }
  end

  def set(x, y)
    @field[y][x] += 1
  end

  def mark(line)
    line.each_point do |p|
      #puts "Marking #{p}"
      set(p.x, p.y)
    end
  end

  def to_s
    @field.map { |row| row.map { |col| col.zero? ? "." : col }.join }.join("\n")
  end

  def each_point
    return enum_for(:each_point) unless block_given?

    @field.each_with_index do |row, y|
      row.each_with_index do |col, x|
        yield [Point.new(x, y), col]
      end
    end
  end
end

input_file = ARGV.shift
lines = File.open(input_file).each_line.map { |line| Line.parse(line) }

field = Field.new(lines)

field.lines.reject(&:diagonal?).each do |line|
  field.mark(line)
end

puts
puts field
puts "Answer for part 1: #{field.each_point.count { |_, n| n >= 2 }}"

field.lines.select(&:diagonal?).each do |line|
  field.mark(line)
end

puts
puts field
puts "Answer for part 2: #{field.each_point.count { |_, n| n >= 2 }}"
