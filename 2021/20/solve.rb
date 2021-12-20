class Enhancement
  attr_reader :bitmap

  def initialize(bitmap_data)
    @bitmap = {}
    bitmap_data.each_with_index do |bit, n|
      @bitmap[n] = bit == "#" ? true : false
    end
  end

  def get(n)
    bitmap[n]
  end
end

class Image
  MARGIN = 2

  Coordinate = Struct.new(:x, :y)

  attr_reader :x_range
  attr_reader :y_range
  attr_reader :pixels
  attr_reader :default

  def self.coordinate(x, y)
    Coordinate.new(x, y)
  end

  def self.read_image(image_data)
    pixels = {}
    image_data.each_with_index do |row, y|
      row.each_with_index do |pixel, x|
        pixels[coordinate(x, y)] = (pixel == "#" ? true : false)
      end
    end

    Image.new(pixels).adjust_ranges
  end

  def initialize(pixels={}, default: false)
    @x_range ||= 0...0
    @y_range ||= 0...0
    @pixels = pixels
    @default = default
  end

  def adjust_ranges
    min_x, max_x = pixels.select { |c, p| p }.keys.map(&:x).minmax
    @x_range = Range.new(min_x-MARGIN, max_x+MARGIN)

    min_y, max_y = pixels.select { |c, p| p }.keys.map(&:y).minmax
    @y_range = Range.new(min_y-MARGIN, max_y+MARGIN)

    self
  end

  def cover?(x, y)
    x_range.cover?(x-MARGIN..x+MARGIN) && y_range.cover?(y-MARGIN..y+MARGIN)
  end

  def expand_ranges(c)
    return if cover?(c.x, c.y)

    @x_range = Range.new([x_range.min, c.x-MARGIN].compact.min, [x_range.max, c.x+MARGIN].compact.max)
    @y_range = Range.new([y_range.min, c.y-MARGIN].compact.min, [y_range.max, c.y+MARGIN].compact.max)
  end

  def pixel(x, y)
    c = Image.coordinate(x, y)
    @pixels[c].nil? ? default : @pixels[c]
  end

  def set_pixel(x, y, v)
    c = Image.coordinate(x, y)
    @pixels[c] = v
    expand_ranges(c) if v
  end

  def image
    y_range.map { |y| x_range.map { |x| pixel(x, y) ? "#" : "." }.join }.join("\n")
  end

  ADJACENT_OFFSETS = [
    [-1, -1],
    [ 0, -1],
    [+1, -1],
    [-1,  0],
    [ 0,  0],
    [+1,  0],
    [-1, +1],
    [ 0, +1],
    [+1, +1],
  ]

  def each_adjacent_pixel(x, y)
    return enum_for(:each_adjacent_pixel, x, y) unless block_given?

    ADJACENT_OFFSETS.map { |ox, oy| [x + ox, y + oy, pixel(x + ox, y + oy)] }.each do |nx, ny, p|
      yield nx, ny, p
    end

    nil
  end

  def enhancement_value(x, y)
    each_adjacent_pixel(x, y).reverse_each.each_with_index.map { |(x, y, p), i| p ? 2**i : 0 }.reduce(:|)
  end

  def each_xy
    return enum_for(:each_xy) unless block_given?

    y_range.each { |y| x_range.each { |x| yield x, y } }

    nil
  end

  def enhance(enhancement)
    new_image = Image.new(@pixels.dup, default: default ^ enhancement.get(0))

    each_xy do |x, y|
      new_image.set_pixel(x, y, enhancement.get(enhancement_value(x, y)))
    end

    new_image.adjust_ranges
  end

  def each_pixel
    return enum_for(:each_pixel) unless block_given?

    each_xy { |x, y| yield x, y, pixel(x, y) }

    nil
  end

end

input_file = ARGV.shift
file = File.open(input_file)
enhancement = Enhancement.new(file.readline.chomp.split(""))
file.readline # discard blank line
image_data = file.each_line.map { |line| line.chomp.split("") }

original_image = Image.read_image(image_data)

puts "Original image:"
puts original_image.image
puts

puts "Processing image for part 1..."
image1 = original_image
(1..2).each do |n|
  puts "Applying enhancement, iteration #{n}..."
  image1 = image1.enhance(enhancement)
  #puts image1.image; puts
end

puts "Final image for part 1:"
puts image1.image
puts

puts "Processing image for part 2..."
image2 = original_image
(1..50).each do |n|
  puts "Applying enhancement, iteration #{n}..."
  image2 = image2.enhance(enhancement)
  #puts image2.image; puts
end

puts "Final image for part 2:"
puts image2.image
puts

answer_part_1 = image1.each_pixel.map { |x, y, p| p }.tally[true]
puts "Answer for part 1: #{answer_part_1}"

answer_part_2 = image2.each_pixel.map { |x, y, p| p }.tally[true]
puts "Answer for part 2: #{answer_part_2}"