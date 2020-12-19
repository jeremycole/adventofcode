class Ticket
  attr_reader :fields, :rules

  def self.parse(rules, line)
    Ticket.new(rules, line.split(',').map(&:to_i))
  end

  def initialize(rules, fields)
    @rules = rules
    @fields = fields
  end

  def invalid_values
    fields.reject { |f| rules.matches_rules?(f) }
  end

  def valid?
    invalid_values.empty?
  end

  def field(index)
    fields[index]
  end
end
