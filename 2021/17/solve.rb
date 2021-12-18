class Point < Struct.new(:x, :y)
end

class Position < Point
  def translate(velocity)
    Position.new(x + velocity.x, y + velocity.y)
  end
end

class Velocity < Point
  def step
    Velocity.new(x.zero? ? 0 : (x + (x.positive? ? -1 : +1)), y - 1)
  end
end

class Area < Point
  def cover?(point)
    x.cover?(point.x) && y.cover?(point.y)
  end

  def beyond?(point)
    point.x > x.max || point.y < y.min
  end
end

class Probe
  attr_reader :steps
  attr_reader :position
  attr_reader :initial_velocity
  attr_reader :velocity
  attr_reader :track

  def initialize(position, initial_velocity)
    @steps = 0
    @position = position
    @initial_velocity = @velocity = initial_velocity
    @track = [@position]
  end

  def step
    @steps += 1
    @position = @position.translate(@velocity)
    @track.push(@position)
    @velocity = @velocity.step

    self
  end

  def max_y
    @track.map(&:y).max
  end
end

def find_successful_probes(target_area, vx_range, vy_range)
  successful_probes = []
  vx_range.each do |vx|
    vy_range.each do |vy|
      probe = Probe.new(Position.new(0, 0), Velocity.new(vx, vy))

      loop do
        probe.step

        if target_area.cover?(probe.position)
          #puts "Probe is in target area!"
          successful_probes << probe
          break
        end

        if target_area.beyond?(probe.position)
          #puts "Probe is beyond target area!"
          break
        end
      end
    end
  end

  successful_probes
end

def save_tracks(probes)
  Dir.mkdir("tracks") unless Dir.exist?("tracks")

  probes.each do |probe|
    track_file = File.join(
      "tracks",
        format(
        "track_%s_%s.csv",
        probe.initial_velocity.x.to_s.gsub("-", "n"),
        probe.initial_velocity.y.to_s.gsub("-", "n")
      )
    )
    File.open(track_file, "w") do |file|
      file.puts "x,y"
      probe.track.each do |track|
        file.puts "#{track.x},#{track.y}"
      end
    end
  end
end

input_file = ARGV.shift
input_line = File.open(input_file).readline.chomp
input_match = /\Atarget area: x=([0-9.-]+), y=([0-9.-]+)/.match(input_line)
raise "bad input file" unless input_match

target_x_range = Range.new(*input_match[1].split("..").map(&:to_i))
target_y_range = Range.new(*input_match[2].split("..").map(&:to_i))

target_area = Area.new(target_x_range, target_y_range)

vx_limit = target_x_range.max
vy_limit = target_y_range.min.abs
successful_probes = find_successful_probes(target_area, 1..vx_limit, -vy_limit..vy_limit)
highest_probe = successful_probes.max_by { |probe| probe.max_y }

save_tracks(successful_probes)

puts "Answer for part 1: #{highest_probe.max_y}"
puts "Answer for part 2: #{successful_probes.size}"
