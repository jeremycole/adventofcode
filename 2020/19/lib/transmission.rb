# frozen_string_literal: true

require 'rule_set'
require 'message_set'

class Transmission
  attr_reader :rule_set, :message_set

  def initialize(filename)
    @rule_set = RuleSet.new
    @message_set = MessageSet.new(@rule_set)
    load_transmission(filename)
  end

  def load_transmission(filename)
    lines = File.open(filename).readlines.map(&:strip)

    while (line = lines.shift)
      break if line == ''

      number, rule = line.strip.split(': ')
      number = number.to_i
      if (m = /"([ab])"/.match(rule))
        rule_set.add(number, CharacterRule.new(rule_set, m[1]))
      else
        alternatives = rule.split(' | ').map do |alternative|
          target_rule_numbers = alternative.split(' ').map(&:to_i)
          JoinRule.new(rule_set, target_rule_numbers.map { |n| RedirectRule.new(rule_set, n) })
        end
        rule_set.add(number, AlternativeRule.new(rule_set, alternatives))
      end
    end

    while (line = lines.shift)
      message_set.add(Message.new(line.strip))
    end

    self
  end

  def valid_messages(rule_number)
    message_set.match(rule_set.rule_regexp(rule_number))
  end
end
