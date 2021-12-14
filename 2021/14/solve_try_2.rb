class Polymer
  attr_reader :pairs
  attr_reader :insertion_rules

  def initialize(template = "")
    @pairs = Hash.new(0)
    @insertion_rules = {}

    # The "*" can be any character that won't appear in a valid pattern.
    # It's just an extra element to be in the last "pair".
    (template + "*").split("").each_cons(2) { |a, b| @pairs[[a, b]] += 1 }
  end

  def add_insertion_rule(a, b, c)
    @insertion_rules[[a, b]] = c
  end

  def calculate_insertions
    insertions = {}

    pairs.each do |(a, b), n|
      next unless n > 0
      next unless @insertion_rules[[a, b]]

      insertions[[a, b]] = [@insertion_rules[[a, b]], n]
    end

    insertions
  end

  def apply_insertions(insertions)
    insertions.each do |(a, b), (c, n)|
      @pairs[[a, b]] -= n
      @pairs[[a, c]] += n
      @pairs[[c, b]] += n
    end
  end
end


input_file = ARGV.shift
file = File.open(input_file)

polymer = Polymer.new(file.readline.chomp)
file.readline

file.each_line do |line|
  if (m = /([A-Z])([A-Z]) -> ([A-Z])/.match(line))
    polymer.add_insertion_rule(m[1], m[2], m[3])
  end
end

#puts polymer.insertion_rules

differences_at_step = []
(1..40).each do |n|
  insertions = polymer.calculate_insertions
  polymer.apply_insertions(insertions)
  #pp polymer.pairs
  element_tally = polymer
    .pairs
    .map { |(a, _), n| [a, n] }
    .reduce(Hash.new(0)) { |h, (a, n)| h[a] += n; h }
    .sort_by { |_, n| n }
  differences_at_step[n] = element_tally.last[1] - element_tally.first[1]
end

puts "Answer for part 1: #{differences_at_step[10]}"
puts "Answer for part 2: #{differences_at_step[40]}"
