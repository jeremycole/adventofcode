class Number
  attr_accessor :parent

  def initialize
    @parent = nil
  end

  def depth
    return 0 unless parent

    parent.depth + 1
  end

  def owned_by(object)
    @parent = object
    root.rechain

    self
  end

  def root
    return parent.root if parent

    self
  end
end

class Regular < Number
  attr_accessor :value
  attr_accessor :left
  attr_accessor :right

  def initialize(value)
    super()
    @value = value
    @left = nil
    @right = nil
  end

  def to_s
    "#{value}"
  end

  def magnitude
    value
  end

  def replace(object, replacement)
    raise "Don't know which object you mean..." unless @value == object

    @value = replacement
    replacement.owned_by(self)

    self
  end

  def should_split?
    value >= 10
  end

  def split
    pair = Pair.new(Regular.new((value / 2.0).floor), Regular.new((value / 2.0).ceil))
    parent.replace(self, pair)

    self
  end

  def flatten
    self
  end
end

class Pair < Number
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    super()
    @parent = nil
    @x = x
    @y = y
    @x.owned_by(self)
    @y.owned_by(self)
  end

  def +(other)
    #puts "  #{self}"
    #puts "+ #{other}"
    sum = Pair.reduce(Pair.new(self, other))
    #puts "= #{sum} (#{sum.magnitude})"
    #puts
    sum
  end

  def to_s
    "[#{x},#{y}]"
  end

  def magnitude
    (3 * x.magnitude) + (2 * y.magnitude)
  end

  def replace(object, replacement)
    raise "Don't know which object you mean..." unless @x == object || @y == object

    @x = replacement if @x == object
    @y = replacement if @y == object
    replacement.owned_by(self)

    self
  end

  def should_explode?
    depth >= 4
  end

  def explode
    x.left.value += x.value if x.left
    y.right.value += y.value if y.right
    parent.replace(self, Regular.new(0))

    self
  end

  def flatten
    [x.flatten, y.flatten].flatten
  end

  def exploders
    ([self] + ([x, y].select { |o| o.is_a?(Pair) }).flat_map(&:exploders)).select(&:should_explode?)
  end

  def splitters
    flatten.select(&:should_split?)
  end

  def rechain
    flatten.each_cons(2) do |a, b|
      a.right = b
      b.left = a
    end

    self
  end

  def self.reduce(pair)
    loop do
      return pair unless pair.exploders.first&.explode || pair.splitters.first&.split
    end
  end

  def self.tokenize(expression)
    expression.chomp.split("")
  end

  def self.parse(tokens)
    token = tokens.shift
    case token
    when "["
      a = parse(tokens)
      raise "missing comma" unless tokens.shift == ","
      b = parse(tokens)
      raise "missing closing bracket" unless tokens.shift == "]"
      return Pair.new(a, b)
    when /[0-9]/
      return Regular.new(token.to_i)
    else
      raise "got some weird token"
    end
  end

  def self.create(expression)
    parse(tokenize(expression))
  end
end

input_file = ARGV.shift
lines = File.open(input_file).readlines

all_snailfish = lines.map { |line| Pair.create(line) }
all_snailfish_sum = all_snailfish.reduce(:+)

puts "Answer for part 1: #{all_snailfish_sum.magnitude}"

snailfish_pairs = lines.product(lines)
                       .reject { |a, b| a == b }
                       .map { |a, b| [Pair.create(a), Pair.create(b)] }

max_sum_snailfish_pair = snailfish_pairs.map { |a, b| a + b }.max_by(&:magnitude)

puts "Answer for part 2: #{max_sum_snailfish_pair.magnitude}"