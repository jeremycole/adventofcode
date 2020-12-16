# frozen_string_literal: true

class Game
  def initialize(starting_numbers)
    @starting_numbers = starting_numbers
    @previous_numbers = {}
    @turn = 0
    @used_numbers = {}
    @last_number = nil
  end

  def turns_since_number(number)
    @used_numbers[number][0] - @used_numbers[number][1]
  end

  def calculate_next_number
    return @starting_numbers.shift unless @starting_numbers.empty?
    return 0 unless @used_numbers.include?(@last_number) && @used_numbers[@last_number].size > 1
    turns_since_number(@last_number)
  end

  def generate_next_number
    this_number = calculate_next_number
    this_turn = @turn
    @used_numbers[this_number] ||= []
    @used_numbers[this_number].unshift(@turn)
    @used_numbers[this_number].pop if @used_numbers[this_number].size > 2
    @last_number = this_number
    @turn += 1

    [this_number, this_turn]
  end

  def each_number
    return to_enum(:each_number) unless block_given?

    loop { yield generate_next_number }

    nil
  end
end
