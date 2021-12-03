class Move
  attr_accessor :direction, :magnitude

  def self.parse(instruction)
    [instruction.chomp.split(/[ ]/)].map { |d, m| new(d, m) }.first
  end

  def initialize(direction, magnitude)
    @direction = direction.to_sym
    @magnitude = magnitude.to_i
  end
end

class Position
  attr_accessor :horizontal, :depth

  def initialize
    @horizontal = 0
    @depth = 0
  end

  def apply(move)
    case move.direction
    when :forward
      @horizontal += move.magnitude
    when :down
      @depth += move.magnitude
    when :up
      @depth -= move.magnitude
    end
  end

  def to_s
    "horizontal: #{horizontal}, depth: #{depth}"
  end
end

input_file = ARGV.shift
moves = File.open(input_file).each_line.map { |instruction| Move.parse(instruction) }

position = Position.new
moves.each do |move|
  position.apply(move)
end

puts "Final position: #{position}"
puts "Answer: #{position.horizontal * position.depth}"
