# frozen_string_literal: true

require 'rule'

class Regulations
  attr_reader :filename, :rules

  def initialize(filename)
    @filename = filename
    @rules = File.open(filename).each_line.map { |line| Rule.parse(line) }
  end

  def rule_by_color
    @rule_by_color ||= rules.each_with_object({}) { |r, h| h[r.color] = r }
  end

  def color(color)
    rule_by_color[color]
  end

  def can_contain(bag)
    @rules.select { |r| r.contains?(bag) }
  end

  def can_eventually_contain(bag, containers=[])
    rules = can_contain(bag)

    containers << rules
    rules.each do |rule|
      containers << can_eventually_contain(rule.color)
    end

    containers.flatten.uniq
  end

  def bag_contains(bag, containers=[])
    rule = color(bag)

    containers << rule
    rule.contains.each do |contained, count|
      containers << { color(contained) => count }
    end

    containers.flatten.uniq
  end
end
