class Rules
  class Rule
    def self.parse(line)
      name, range_string = line.strip.split(': ')
      ranges = range_string.split(' or ').map { |s| s.split('-') }.map { |a, b| Range.new(a.to_i, b.to_i) }
      Rule.new(name, ranges)
    end

    attr_reader :name, :ranges

    def initialize(name, ranges)
      @name = name
      @ranges = ranges
    end

    def matches_rule?(number)
      ranges.any? { |r| r.include?(number) }
    end

    def valid_for?(numbers)
      numbers.all? { |n| matches_rule?(n) }
    end
  end

  attr_reader :rules

  def initialize
    @rules = []
  end

  def parse_rule(line)
    @rules.push(Rule.parse(line))
  end

  def matches_rules?(number)
    rules.any? { |r| r.matches_rule?(number) }
  end

  def valid_for?(numbers)
    rules.select { |r| r.valid_for?(numbers) }
  end
end