require 'seat'

class Layout
  attr_reader :filename, :seats

  DIRECTIONS = ([-1, 0, +1].product([-1, 0, +1]) - [[0, 0]]).freeze

  def initialize(filename)
    @filename = filename

    lines = File.open(filename).readlines.map(&:strip)

    @seats = lines.each_with_index.map do |line, y|
      line.split('').each_with_index.map do |c, x|
        c == 'L' ? Seat.new(self, x, y) : Floor.new(self, x, y)
      end
    end
  end

  def height
    @height ||= @seats.size
  end

  def width
    @width ||= @seats.first.size
  end

  def remap_coordinates(x, y, offsets)
    offsets
      .map { |xo, yo| [x + xo, y + yo] }
      .reject { |nx, ny| nx < 0 || ny < 0 || nx >= width || ny >= height }
  end

  def adjacent_coordinates(x, y)
    remap_coordinates(x, y, DIRECTIONS)
  end

  def visible_maximum_distance
    height + width
  end

  def multiply_distance(direction, distance)
    direction.map { |i| i * distance }
  end

  def visible_coordinates_in_direction(direction, x, y)
    (1..visible_maximum_distance).flat_map do |distance|
      remap_coordinates(x, y, [multiply_distance(direction, distance)])
    end
  end

  def adjacent_seats(seat)
    adjacent_coordinates(seat.x, seat.y).map { |x, y| seats[y][x] }
  end

  def first_seat_in_direction(seat, direction)
    visible_coordinates_in_direction(direction, seat.x, seat.y).each do |x, y|
      return seats[y][x] if seats[y][x].occupiable?
    end

    nil
  end

  def visible_seats(seat)
    DIRECTIONS.map { |direction| first_seat_in_direction(seat, direction) }.compact
  end

  def inspect
    "#<Layout height=#{height}, width=#{width} ...>"
  end

  def print
    seats.each do |row|
      puts row.map(&:to_s).join('')
    end

    nil
  end

  def each_seat
    return to_enum(:each_seat) unless block_given?

    seats.each do |row|
      row.select(&:occupiable?).each do |seat|
        yield seat
      end
    end

    nil
  end
end
