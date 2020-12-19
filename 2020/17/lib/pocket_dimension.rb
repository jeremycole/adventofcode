require 'vector3d'
require 'cube'

class PocketDimension
  attr_reader :cubes

  def initialize(filename)
    @cubes = {}

    dim = File.open(filename).readlines.map { |line| line.strip.split('').map { |x| x == '#' } }
    dim.each_with_index do |row, y|
      row.each_with_index do |value, x|
        cube(Vector3d.new(x, y, 0), value)
      end
    end
  end

  def cube(coordinate, status = false)
    @cubes[coordinate] ||= Cube.new(self, coordinate, status)
  end

  def minmax(dimension, expansion = 0)
    @cubes
      .select { |_, cube| cube.active? }
      .keys
      .minmax_by(&dimension)
      .map(&dimension)
      .inject { |min, max| [min - expansion, max + expansion] }
  end

  def range(dimension, expansion = 0)
    Range.new(*minmax(dimension, expansion))
  end

  def range_xyz(expansion = 0)
    %i[x y z].map { |d| range(d, expansion) }
  end

  def each_xyz_coordinate(expansion = 0)
    return to_enum(:each_xyz_coordinate, expansion) unless block_given?

    range_xyz(expansion).reduce { |a, b| a.to_a.product(b.to_a) }.map { |a| a.flatten }.each do |x, y, z|
      yield Vector3d.new(x, y, z)
    end
  end

  def each_cube
    return to_enum(:each_cube) unless block_given?

    @cubes.each do |_, cube|
      yield cube
    end

    nil
  end

  def each_cube_and_active_neighbor_count
    return to_enum(:each_cube_and_active_neighbor_count) unless block_given?

    each_xyz_coordinate(1).each do |c|
      this_cube = cube(c)
      yield this_cube, this_cube.neighbors.count { |n| n.status }
    end

    nil
  end

  def dump
    range(:z).each do |z|
      puts "z=#{z}:"
      range(:y).each do |y|
        range(:x).each do |x|
          print cube(Vector3d.new(x, y, z))
        end
        puts
      end
      puts
    end

    nil
  end
end
