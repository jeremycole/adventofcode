require 'vector4d'

class Cube
  attr_accessor :status
  attr_reader :pocket_dimension, :coordinate

  def initialize(pocket_dimension, coordinate, status)
    @pocket_dimension = pocket_dimension
    @coordinate = coordinate
    @status = status
  end

  def to_s
    status ? '#' : '.'
  end

  def neighbors
    coordinate.adjacent.map { |v| @pocket_dimension.cube(v) }
  end

  def active?
    status == true
  end

  def inactive?
    !active?
  end
end
