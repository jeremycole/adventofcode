# frozen_string_literal: true

class JoinRule
  attr_reader :rule_set, :components

  def initialize(rule_set, components)
    @rule_set = rule_set
    @components = components
  end

  def to_regexp
    components.map(&:to_regexp).join
  end
end
