class List
  class Item
    attr_reader :item
    attr_accessor :next_item

    def initialize(item, next_item=nil)
      @item = item
      @next_item = next_item
    end
  end

  attr_reader :first

  def initialize
    @first_item = nil
  end

  def each
    return enum_for(:each) unless block_given?

    item = @first_item

    until item.nil?
      yield item
      item = item.next_item
    end

    nil
  end

  def last
    each.to_a.last
  end

  def append(item)
    if @first_item
      item.next_item = nil
      last.next_item = item
    else
      @first_item = item
    end

    item
  end

  def insert(at, item)
    item.next_item = at.next_item
    at.next_item = item

    item
  end
end

class Element
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Polymer
  attr_reader :chain
  attr_reader :insertion_rules

  def initialize(template = "")
    @chain = List.new
    @insertion_rules = {}

    template.split("").each { |name| append(name) }
  end

  def each_element
    return enum_for(:each_element) unless block_given?

    chain.each do |item|
      yield item.item.name
    end

    nil
  end

  def element(name)
    List::Item.new(Element.new(name))
  end

  def insert(at, name)
    chain.insert(at, element(name))
  end

  def append(name)
    chain.append(element(name))
  end

  def add_insertion_rule(before, after, name)
    @insertion_rules[[before, after]] = name
  end

  def to_s
    each_element.to_a.join
  end

  def calculate_insertions
    insertions = {}

    chain.each.each_cons(2) do |a, b|
      next unless @insertion_rules[[a.item.name, b.item.name]]

      insertions[a] = @insertion_rules[[a.item.name, b.item.name]]
    end

    insertions
  end

  def apply_insertions(insertions)
    insertions.each do |before, name|
      insert(before, name)
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

puts polymer.to_s
puts polymer.insertion_rules

(1..10).each do |n|
  polymer.apply_insertions(polymer.calculate_insertions)
  #puts "After step #{n}: #{polymer}"
end

element_tally = polymer.each_element.to_a.tally.sort_by { |name, count| count }

puts element_tally.last[1] - element_tally.first[1]
pp