# frozen_string_literal: true

class Seat
  attr_reader :identifier

  def initialize(identifier)
    # FBBFBBBLLR
    @identifier = identifier
  end

  def row
    identifier[0..6].tr('FB', '01').to_i(2)
  end

  def column
    identifier[7..10].tr('LR', '01').to_i(2)
  end

  def seat_id
    row * 8 + column
  end
end
