# frozen_string_literal: true

class ImageData
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def dump
    puts data.map { |row| row.map { |cell| cell ? '#' : '.' }.join }.join("\n")
  end

  def calculate_edge_identity(edge_data)
    edge_data.each_with_index.map { |b, i| b ? 2**i : 0 }.reduce(:|)
  end

  def edge_identity(number)
    case number
    when 0
      calculate_edge_identity(data.first)
    when 1
      calculate_edge_identity(data.map(&:last))
    when 2
      calculate_edge_identity(data.last)
    when 3
      calculate_edge_identity(data.map(&:first))
    else
      raise "unknown edge number #{number}"
    end
  end

  def edge_identities
    (0..3).map { |n| edge_identity(n) }
  end

  def original
    self
  end

  def no_flip
    original
  end

  def no_rotate
    original
  end

  def flip_vertical
    ImageData.new(data.reverse)
  end

  def flip_horizontal
    ImageData.new(data.map(&:reverse))
  end

  def flip_both
    flip_vertical.flip_horizontal
  end

  def transpose
    ImageData.new(data.transpose)
  end

  def rotate_clockwise
    transpose.flip_horizontal
  end

  def rotate_0
    original
  end

  def rotate_1
    rotate_clockwise
  end

  def rotate_2
    rotate_clockwise.rotate_clockwise
  end

  def rotate_3
    rotate_clockwise.rotate_clockwise.rotate_clockwise
  end

  def transform(flip, rotate)
    send(flip).send(rotate)
  end

  def body
    ImageData.new(data[1..-2].map { |a| a[1..-2] })
  end

  def contains?(image, x, y)
    image.data.each_index do |iy|
      image.data[iy].each_index do |ix|
        return false if image.data[iy][ix] && !data[y+iy][x+ix]
      end
    end

    true
  end

  def each_contained_image(image)
    return to_enum(:each_contained_image, image) unless block_given?

    (0..(data.size - image.data.size)).each do |y|
      (0..(data.first.size - image.data.first.size)).each do |x|
        yield x, y if contains?(image, x, y)
      end
    end

    nil
  end
end
