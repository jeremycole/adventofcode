# frozen_string_literal: true

class RedirectRule
  attr_reader :rule_set, :target_rule_number

  def initialize(rule_set, target_rule_number)
    @rule_set = rule_set
    @target_rule_number = target_rule_number
  end

  def target_rule
    rule_set.rule(target_rule_number)
  end

  def to_regexp
    @to_regexp ||= target_rule.to_regexp
  end
end
