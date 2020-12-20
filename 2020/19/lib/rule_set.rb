# frozen_string_literal: true

require 'character_rule'
require 'join_rule'
require 'alternative_rule'

class RuleSet
  attr_reader :rules

  def initialize
    @rules = []
  end

  def inspect
    "#<#{self.class.name} rules=[#{rules.size} items] ...>"
  end

  def add(number, rule)
    rules[number] = rule
  end

  def rule(number)
    rules[number]
  end

  def rule_regexp(number)
    Regexp.new("^#{rule(number).to_regexp}$")
  end
end
