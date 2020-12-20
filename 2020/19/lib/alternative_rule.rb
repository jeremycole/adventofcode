# frozen_string_literal: true

require 'redirect_rule'

class AlternativeRule
  attr_reader :rule_set, :alternatives

  def initialize(rule_set, alternatives)
    @rule_set = rule_set
    @alternatives = alternatives
  end

  def to_regexp
    @to_regexp ||= format('(%s)', alternatives.map(&:to_regexp).join('|'))
  end
end