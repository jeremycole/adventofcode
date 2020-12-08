# frozen_string_literal: true

class Rule
  def self.parse_contains(contains)
    return [] if contains == 'no other'

    contains.split(', ').each_with_object({}) do |content, h|
      if (m = /(\d+) (.+) bag(s?)/.match(content))
        h[m[2]] = m[1].to_i
      end
    end
  end

  def self.parse(rule)
    if (m = /^(.+) bags contain (.+)\./.match(rule.strip))
      Rule.new(m[1], parse_contains(m[2]))
    end
  end

  attr_reader :color, :contains

  def initialize(color, contains)
    @color = color
    @contains = contains
  end

  def contains?(color)
    contains.include?(color)
  end
end
