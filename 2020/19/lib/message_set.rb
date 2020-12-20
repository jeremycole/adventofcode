# frozen_string_literal: true

require 'message'

class MessageSet
  attr_reader :rule_set, :messages

  def initialize(rule_set)
    @rule_set = rule_set
    @messages = []
  end

  def inspect
    "#<#{self.class.name} messages=[#{messages.size} items] ...>"
  end

  def add(message)
    messages.push(message)
  end

  def match(regexp)
    messages.select { |m| m.match(regexp) }
  end
end
