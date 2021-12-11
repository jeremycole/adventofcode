class Cavern
  ADJACENT_OFFSETS = [
    [-1, -1],
    [-1, 0],
    [-1, +1],
    [0, +1],
    [+1, +1],
    [+1, 0],
    [+1, -1],
    [0, -1],
  ]

  attr_reader :step_number
  attr_reader :grid
  attr_reader :rows
  attr_reader :cols

  def initialize(grid)
    @step_number = 0
    @grid = grid
    @rows = grid.size
    @cols = grid.first.size

    each_octopus { |o| o.home(self) }
  end

  def to_s
    grid.map { |row| row.map { |octopus| octopus.draw }.join }.join("\n")
  end

  def x_range
    (0...@cols)
  end

  def y_range
    (0...@rows)
  end

  def each_octopus
    return enum_for(:each_octopus) unless block_given?

    grid.each do |row|
      row.each do |octopus|
        yield octopus
      end
    end

    nil
  end

  def octopus_at(x, y)
    return unless x_range.cover?(x) && y_range.cover?(y)

    @grid[y][x]
  end

  def step
    @step_number += 1
    each_octopus(&:step)
    each_octopus.each(&:flash!)
  end

  def adjacent_octopuses(octopus)
    ADJACENT_OFFSETS.map { |ax, ay| octopus_at(octopus.x + ax, octopus.y + ay) }.compact
  end
end

class Octopus
  attr_reader :last_flash_step_number
  attr_reader :flash_count
  attr_reader :x
  attr_reader :y
  attr_reader :energy
  attr_reader :cavern

  def initialize(x, y, energy)
    @last_flash_step_number = nil
    @flash_count = 0
    @x = x
    @y = y
    @energy = energy
    @cavern = nil
  end

  def home(cavern)
    @cavern = cavern
  end

  def to_s
    "(#{x}, #{y}) @#{energy}#{ready_to_flash? ? "!" : ""}"
  end

  def draw
    ready_to_flash? ? "!" : energy.to_s
  end

  def step
    @energy += 1
  end

  def flashed_this_step?
    @last_flash_step_number == @cavern.step_number
  end

  def ready_to_flash?
    energy > 9 && !flashed_this_step?
  end

  def adjacent
    cavern.adjacent_octopuses(self)
  end

  def flash!
    return unless ready_to_flash?

    @flash_count += 1
    @last_flash_step_number = @cavern.step_number
    @energy = 0
    adjacent.each(&:adjacent_flash!)

    nil
  end

  def adjacent_flash!
    return if flashed_this_step?

    @energy += 1
    flash!
  end
end

input_file = ARGV.shift
energy_levels = File.open(input_file).each_line.map { |line| line.chomp.split("").map(&:to_i) }

octopuses = energy_levels.each_with_index.map { |row, y| row.each_with_index.map { |energy, x| Octopus.new(x, y, energy) } }

cavern = Cavern.new(octopuses)

all_flashed = nil

100.times do
  cavern.step

  # puts "\nStep #{cavern.step_number}:"
  # puts cavern

  all_flashed = cavern.step_number if cavern.each_octopus.all?(&:flashed_this_step?)
end

answer_part_1 = cavern.each_octopus.map(&:flash_count).sum
puts "Answer for part 1: #{answer_part_1}"

until all_flashed
  cavern.step
  all_flashed = cavern.step_number if cavern.each_octopus.all?(&:flashed_this_step?)
end

puts "Answer for part 2: #{all_flashed}"
