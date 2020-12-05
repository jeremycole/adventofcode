# frozen_string_literal: true

require 'seat'

class SeatFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def each_seat
    return enum_for(:each_seat) unless block_given?

    File.open(filename).each_line do |line|
      yield Seat.new(line.strip)
    end

    nil
  end
end
