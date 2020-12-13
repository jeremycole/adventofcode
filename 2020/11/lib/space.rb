class Space
  attr_reader :layout, :x, :y

  def initialize(layout, x, y)
    @layout = layout
    @x = x
    @y = y
  end

  def to_s
    '.'
  end

  def occupied?
    false
  end

  def empty?
    !occupied?
  end

  def occupiable?
    false
  end
end

class Floor < Space; end
