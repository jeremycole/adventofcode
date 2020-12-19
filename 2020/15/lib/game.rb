# frozen_string_literal: true

class Game
  def initialize(starting_numbers)
    @starting_numbers = starting_numbers
    @previous_numbers = {}
    @next_turn = 0
    @used_numbers = {}
    @last_number = nil
  end

  def turns_since_number(number)
    used_number = @used_numbers[number]
    used_number[0] - used_number[1]
  end

  def calculate_next_number
    return @starting_numbers.shift unless @starting_numbers.empty?

    used_number = @used_numbers[@last_number]
    return 0 unless used_number && used_number.size > 1

    turns_since_number(@last_number)
  end

  def generate_next_number
    number = calculate_next_number
    turn = @next_turn
    used_number = @used_numbers[number] ||= []
    used_number.unshift(@next_turn)
    used_number.pop if used_number.size > 2
    @last_number = number
    @next_turn += 1

    [number, turn]
  end

  def each_number
    return to_enum(:each_number) unless block_given?

    loop { yield generate_next_number }

    nil
  end
end
