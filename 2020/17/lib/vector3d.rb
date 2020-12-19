class Vector3d
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_a
    [x, y, z]
  end

  def hash
    x.hash ^ y.hash ^ z.hash
  end

  def ==(other)
    x == other.x && y == other.y && z == other.z
  end

  def eql?(other)
    self == other
  end

  def +(other)
    Vector3d.new(x + other.x, y + other.y, z + other.z)
  end

  def adjacent
    ADJACENT_VECTORS.map { |v| self + v }
  end

  ADJACENT_INCREMENTS = [-1, 0, +1].freeze

  SELF_AND_ADJACENT_OFFSETS =
    ADJACENT_INCREMENTS
    .product(ADJACENT_INCREMENTS)
    .product(ADJACENT_INCREMENTS)
    .map(&:flatten)
    .freeze

  ADJACENT_OFFSETS = (SELF_AND_ADJACENT_OFFSETS - [[0, 0, 0]]).freeze

  ADJACENT_VECTORS =
    ADJACENT_OFFSETS
    .map { |x, y, z| Vector3d.new(x, y, z) }
    .freeze

end
