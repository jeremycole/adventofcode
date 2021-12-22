class Plane
  attr_reader :axis
  attr_reader :value

  def initialize(axis, value)
    @axis = axis
    @value = value
  end

  def to_a
    [@axis, @value]
  end

  def hash
    to_a.hash
  end

  def ==(other)
    to_a == other.to_a
  end

  def eql?(other)
    to_a == other.to_a
  end
end

class Cuboid
  attr_reader :x_range
  attr_reader :y_range
  attr_reader :z_range

  def self.parse(string)
    new(*string.split(",").map { |part| Range.new(*part.sub(/[xyz]=/, "").split("..").map(&:to_i)) })
  end

  def initialize(x_range, y_range, z_range)
    @x_range = x_range
    @y_range = y_range
    @z_range = z_range
  end

  def ranges
    @ranges ||= { x: x_range, y: y_range, z: z_range }
  end

  def cover?(x, y, z)
    x_range.cover?(x) && y_range.cover?(y) && z_range.cover?(z)
  end

  def same?(x, y=nil, z=nil)
    return same?(x.x_range, x.y_range, x.z_range) if x.is_a?(Cuboid)

    x == x_range && y == y_range && z == z_range
  end

  def overlap?(x, y=nil, z=nil)
    return overlap?(x.x_range, x.y_range, x.z_range) if x.is_a?(Cuboid)

    (x_range.cover?(x.min) || x_range.cover?(x.max) || x.cover?(x_range)) && (y_range.cover?(y.min) || y_range.cover?(y.max) || y.cover?(y_range)) && (z_range.cover?(z.min) || z_range.cover?(z.max) || z.cover?(z_range))
  end

  def size
    x_range.size * y_range.size * z_range.size
  end

  def each_xyz
    return enum_for(:each_xyz) unless block_given?

    x_range.each { |x| y_range.each { |y| z_range.each { |z| yield x, y, z } } }

    nil
  end

  def planes
    [:x, :y, :z].flat_map { |axis| ranges[axis].minmax.flat_map { |value| Plane.new(axis, value) } }
  end

  def intersected_by_plane?(plane)
    range = ranges[plane.axis]

    range.cover?(plane.value) && !(range.min == plane.value || range.max == plane.value)
  end

  def split(plane)
    return [Cuboid.new(x_range, y_range, z_range)] unless intersected_by_plane?(plane)

    case plane.axis
    when :x
      [Cuboid.new(x_range.min...plane.value, y_range, z_range), Cuboid.new(plane.value..x_range.max, y_range, z_range)]
    when :y
      [Cuboid.new(x_range, y_range.min...plane.value, z_range), Cuboid.new(x_range, plane.value..y_range.max, z_range)]
    when :z
      [Cuboid.new(x_range, y_range, z_range.min...plane.value), Cuboid.new(x_range, y_range, plane.value..z_range.max)]
    end
  end
end

class Step
  attr_reader :state
  attr_reader :cuboids

  def initialize(state, cuboids)
    @state = state.to_sym == :on ? true : false
    @cuboids = cuboids
  end

  def split(planes)
    planes.each_with_index do |plane, n|
      puts "splitting #{@cuboids.size} by plane #{n}..."
      @cuboids = @cuboids.flat_map { |cuboid| cuboid.intersected_by_plane?(plane) ? cuboid.split(plane) : cuboid }.uniq
    end

    self
  end
end

class Reactor
  attr_reader :cubes

  def initialize
    @cubes = Hash.new(false)
  end

  def apply(step)
    step.cuboid.each_xyz do |x, y, z|
      @cubes[[x, y, z]] = step.state
    end
  end
end

if ARGV.size > 0
  input_file = ARGV.shift
  steps = File.open(input_file).each_line.flat_map { |line| line.chomp.split(" ").each_cons(2).map { |state, cuboid| Step.new(state.to_sym, Cuboid.parse(cuboid)) } }

  test_cuboid = Cuboid.new(-50..50, -50..50, -50..50)

  reactor = Reactor.new
  steps.each do |step|
    next unless step.cuboid.overlap?(*test_cuboid.ranges.keys)
    puts "Applying step: #{step} #{step.cuboid.ranges} (#{step.cuboid.size})"
    reactor.apply(step)
  end
  pp reactor.cubes.count { |xyz, state| state && test_cuboid.cover?(*xyz) }
end

# steps = File.open("input.txt").each_line.flat_map { |line| line.chomp.split(" ").each_cons(2).map { |state, cuboid| Step.new(state.to_sym, [Cuboid.parse(cuboid)]) } }
# planes = steps.flat_map(&:cuboids).flat_map(&:planes).uniq
# steps.each_with_index { |step, n| puts "Working on step #{n} with #{step.cuboids.size} cuboids..."; step.split(planes); puts "... now #{step.cuboids.size} cuboids!" }; nil
# steps.flat_map { |step| step.cuboids.map { |cuboid| [cuboid, step.state] } }.to_h.select { |k, v| v }.keys.sum(&:size)