# frozen_string_literal: true

require 'tile'
require 'vector'

class Image
  attr_reader :tiles, :field

  def initialize(filename)
    @tiles = {}
    @field = nil
    load_tiles(filename)
    initialize_empty_field
  end

  def load_tiles(filename)
    file = File.open(filename)
    number = nil
    data = []
    file.each_line do |line|
      line = line.strip

      if line.empty?
        add_tile(number, data)
        number = nil
        data = []
        next
      end

      if (m = /Tile (\d+):/.match(line))
        number = m[1].to_i
        next
      end

      data.push(line.split('').map { |x| x == '#'})
    end

    add_tile(number, data) if number
  end

  def initialize_empty_field
    size = Math.sqrt(tiles.size).to_i
    @field = size.times.map { [nil] * size }
  end

  def add_tile(number, data)
    @tiles[number] = Tile.new(self, number, data)
  end

  def each_tile
    return to_enum(:each_tile) unless block_given?

    tiles.each_value do |tile|
      yield tile
    end

    nil
  end

  def joinable_tiles
    @joinable_tiles ||= each_tile.each_with_object({}) do |a, h|
      h[a] = each_tile.select { |b| a.joins?(b) }
    end
  end

  def corner_tiles
    joinable_tiles.select { |_, tiles| tiles.size == 2 }.keys
  end

  ADJACENT_OFFSETS = {
    0 => [0, -1],
    1 => [+1, 0],
    2 => [0, +1],
    3 => [-1, 0]
  }.freeze
  ADJACENT_VECTORS = ADJACENT_OFFSETS.map { |edge, (x, y)| [edge, Vector.new(x: x, y: y)] }.to_h.freeze

  JOINED_EDGES = {
    0 => 2,
    1 => 3,
    2 => 0,
    3 => 1,
  }.freeze

  def adjacent_tiles(x, y)
    t = Vector.new(x: x, y: y)
    ADJACENT_VECTORS
      .map { |e, v| [e, t + v] }
      .select { |e, v| v.in_range?(0...field.size, 0...field.first.size) }
      .map { |e, v| [e, field[v.y][v.x]] }
      .reject { |e, t| t.nil? }
      .to_h
  end

  def fill_field
    field[0][0] = corner_tiles[0]
    field[0][1] = corner_tiles[0].joinable_tiles[0]
    field[1][0] = corner_tiles[0].joinable_tiles[1]

    field.each_index do |y|
      field[y].each_index do |x|
        next if field[y][x]

        joinable_range = case
        when (y.zero? || y == field.size - 1) && (x.zero? || x == field[y].size - 1)
          2
        when (y.zero? || y == field.size - 1) && x < field[y].size - 1
          3
        when x.zero? || x == field[y].size - 1
          3
        else
          4
        end

        field[y][x] = adjacent_tiles(x, y).map { |_, t| t.joinable_tiles.select { |t| joinable_range == t.joinable_tiles.size } - field.flatten }.reduce(:&).first
      end
    end

    self
  end

  def possible_orientations(x, y)
    ta = field[y][x]
    orientations = adjacent_tiles(x, y).map do |e, tb|
      ta.edge_identities.select { |_, x| (ta.edge_identities.map { |_, v| v[e] } & tb.edge_identities.map { |_, v| v[JOINED_EDGES[e]] }).include?(x[e]) }.keys
    end
    orientations.reduce(:&)
  end

  def reorient
    field.each_index do |y|
      field[y].each_index do |x|
        field[y][x].transform(*possible_orientations(x, y).first)
      end
    end

    self
  end

  def extract
    image_bodies = field.each_index.map do |y|
      field[y].each_index.map do |x|
        field[y][x].image_data.body
      end
    end

    full_image = image_bodies.map { |rows| rows.map(&:data).reduce { |a, b| a.each_index.map { |i| a[i] + b[i] } } }.reduce(:+)

    ImageData.new(full_image)
  end
end
