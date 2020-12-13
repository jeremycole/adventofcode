# frozen_string_literal: true

class Vector
  attr_accessor :complex

  def initialize(x: 0, y: 0)
    @complex = x + (1i * y)
  end

  def x
    complex.real
  end

  def y
    complex.imag
  end

  def +(v)
    Vector.new(x: x + v.x, y: y + v.y)
  end

  def *(s)
    Vector.new(x: x * s, y: y * s)
  end

  def rotate(steps)
    steps.abs.times { self.complex *= steps.positive? ? -1i : +1i }

    self
  end

  def manhattan_distance(v = Vector.new)
    (v.x - x).abs + (v.y - y).abs
  end
end
