class Pair < Struct.new(:open, :close)
  PAIRS = [
    Pair.new("(", ")"),
    Pair.new("[", "]"),
    Pair.new("{", "}"),
    Pair.new("<", ">"),
  ]

  LOOKUP = PAIRS.each.flat_map { |p| [[p.open, [:open, p]], [p.close, [:close, p]]] }.to_h
  MATCHING = PAIRS.each.flat_map { |p| [[p.open, p.close], [p.close, p.open]] }.to_h
end

class Chunk
  attr_reader :chunk

  def initialize(chunk)
    @chunk = chunk
  end

  def validate
    stack = []
    chunk.split("").each do |char|
      type, pair = Pair::LOOKUP[char]
      case type
      when :open
        stack.push(char)
      when :close
        expected = stack.pop
        return [expected, char] unless expected == pair.open
      end
    end

    return [stack.map { |c| Pair::MATCHING[c] }.reverse, nil] unless stack.empty?

    nil
  end
end

PART_1_POINTS = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137,
}

PART_2_POINTS = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}

input_file = ARGV.shift
chunks = File.open(input_file).each_line.map { |line| Chunk.new(line.chomp) }

answer_part_1 = chunks
  .map(&:validate)
  .reject { |_, f| f == nil }
  .map { |_, f| PART_1_POINTS[f] }
  .sum

puts "Answer to part 1: #{answer_part_1}"

scores_part_1 = chunks
  .map(&:validate)
  .select { |e, f| e != nil && f == nil }
  .map { |e, _| e.inject(0) { |sum, x| (5 * sum) + PART_2_POINTS[x] } }
  .sort

answer_part_2 = scores_part_1[scores_part_1.size / 2]

puts "Answer to part 2: #{answer_part_2}"
