class Vector4d
  attr_accessor :x, :y, :z, :w

  def initialize(x, y, z = 0, w = 0)
    @x = x
    @y = y
    @z = z
    @w = w
  end

  def to_a
    [x, y, z, w]
  end

  def hash
    x.hash ^ y.hash ^ z.hash ^ w.hash
  end

  def ==(other)
    x == other.x && y == other.y && z == other.z && w == other.w
  end

  def eql?(other)
    self == other
  end

  def +(other)
    Vector4d.new(x + other.x, y + other.y, z + other.z, w + other.w)
  end

  def adjacent
    ADJACENT_VECTORS.map { |v| self + v }
  end

  ADJACENT_INCREMENTS = [-1, 0, +1].freeze

  SELF_AND_ADJACENT_OFFSETS =
    ADJACENT_INCREMENTS
    .product(ADJACENT_INCREMENTS)
    .product(ADJACENT_INCREMENTS)
    .product(ADJACENT_INCREMENTS)
    .map(&:flatten)
    .freeze

  ADJACENT_OFFSETS = (SELF_AND_ADJACENT_OFFSETS - [[0, 0, 0, 0]]).freeze

  ADJACENT_VECTORS =
    ADJACENT_OFFSETS
    .map { |x, y, z, w| Vector4d.new(x, y, z, w) }
    .freeze
end
