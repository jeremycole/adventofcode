# frozen_string_literal: true

class CharacterRule
  attr_reader :rule_set, :character

  def initialize(rule_set, character)
    @rule_set = rule_set
    @character = character
  end

  def to_regexp
    character
  end
end
