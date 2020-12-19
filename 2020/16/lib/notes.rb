require 'rules'
require 'ticket'

class Notes
  attr_reader :rules, :my_ticket, :nearby_tickets

  def initialize(filename)
    @rules = Rules.new
    @my_ticket = nil
    @nearby_tickets = []

    load(filename)
  end

  def load(filename)
    File.open(filename) do |file|
      loop do
        line = file.readline.strip
        break if line.empty?

        rules.parse_rule(line)
      end

      file.readline # your ticket:
      @my_ticket = Ticket.parse(rules, file.readline.strip)

      file.readline # blank

      file.readline # nearby tickets:
      file.readlines.each do |line|
        nearby_tickets.push(Ticket.parse(rules, line.strip))
      end
    end

    self
  end

end
