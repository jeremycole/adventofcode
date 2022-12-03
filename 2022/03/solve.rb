# frozen_string_literal: true

class Item
  PRIORITIES = (("a".."z").to_a + ("A".."Z").to_a).each_with_index.to_h { |l, v| [l, v+1] }

  attr_reader :type

  def initialize(type)
    @type = type
  end

  def eql?(other)
    type.eql?(other.type)
  end
  alias == eql?

  def hash
    type.hash
  end

  def priority
    PRIORITIES[type]
  end
end

class Compartment
  attr_reader :items

  def initialize(items)
    @items = items
  end

  def item_types
    items.map(&:type)
  end
end

class Rucksack
  attr_reader :compartments

  def self.from_s(input)
    new(input.split("").map { |x| Item.new(x) }.each_slice(input.size / 2).map { |x| Compartment.new(x) })
  end

  def initialize(compartments)
    @compartments = compartments
  end

  def overlap
    compartments.map(&:items).reduce(:&).first
  end

  def items
    compartments.flat_map { |compartment| compartment.items }
  end
end

input_file = ARGV.shift
rucksacks = File.open(input_file).each_line.map { |line| Rucksack.from_s(line.chomp) }

puts rucksacks.map(&:overlap).map(&:priority).sum

puts rucksacks.map(&:items).each_slice(3).map { |group| group.reduce(:&).first }.map(&:priority).sum
