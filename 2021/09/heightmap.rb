#!/usr/bin/env ruby

class Heightmap
  attr_reader :heightmap
  attr_reader :height
  attr_reader :width

  def initialize(file)
    @heightmap = load_heightmap(file)
    @height = @heightmap.size
    @width = @heightmap.first&.size
  end

  def load_heightmap(file)
    @heightmap = File.open(file).each_line.map { |l| l.chomp.split("").map(&:to_i) }
  end

  def x_range
    (0...@width)
  end

  def y_range
    (0...@height)
  end

  def each_xy
    return enum_for(:each_xy) unless block_given?

    y_range.each { |y| x_range.each { |x| yield x, y } }

    nil
  end

  def point(x, y)
    return nil unless x_range.cover?(x) && y_range.cover?(y)

    @heightmap[y][x]
  end

  ADJACENT_OFFSETS = [
    [-1, 0],
    [+1, 0],
    [0, -1],
    [0, +1],
  ]

  def each_point
    return enum_for(:each_point) unless block_given?

    each_xy do |x, y|
      yield x, y, point(x, y)
    end

    nil
  end

  def each_adjacent_point(x, y)
    return enum_for(:each_adjacent_point, x, y) unless block_given?

    ADJACENT_OFFSETS.map { |ox, oy| [x + ox, y + oy, point(x + ox, y + oy)] }.each do |nx, ny, p|
      yield nx, ny, p if p
    end

    nil
  end

  def each_low_point
    return enum_for(:each_low_point) unless block_given?

    each_point do |x, y, p|
      yield x, y, p if each_adjacent_point(x, y).all? { |_ax, _ay, ap| p < ap }
    end

    nil
  end

  def each_adjacent_slope(x, y, p)
    return enum_for(:each_adjacent_slope, x, y, p) unless block_given?

    each_adjacent_point(x, y) do |ax, ay, ap|
      yield ax, ay, ap if ap != 9 && ap > p
    end

    nil
  end

  def points_in_basin(x, y, p, basin=[])
    return [] if basin.include?([x, y, p])

    adjacent_points_in_basin = each_adjacent_slope(x, y, p).flat_map do |ax, ay, ap|
      [[ax, ay, ap]] | points_in_basin(ax, ay, ap, basin).map { |bx, by, bp| [bx, by, bp] }
    end

    basin | [[x, y, p]] | adjacent_points_in_basin
  end

  def each_basin
    return enum_for(:each_basin) unless block_given?

    each_low_point { |x, y, p| yield points_in_basin(x, y, p) }

    nil
  end
end
