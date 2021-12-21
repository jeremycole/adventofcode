class DeterministicDice
  attr_reader :rolls

  def initialize
    @rolls = 0
    @dice = (1..100).cycle
  end

  def roll
    @rolls += 1
    @dice.next
  end
end

module Dirac
  class Position
    attr_reader :cycler
    attr_reader :current

    def initialize(space)
      @cycler = (1..10).cycle
      move(space)
    end

    def move(spaces)
      @current = spaces.times.map { cycler.next }.last
    end
  end

  class Player
    attr_reader :game
    attr_reader :number
    attr_reader :position
    attr_reader :score
    attr_reader :rolls

    def initialize(game, number, position)
      @game = game
      @number = number
      @position = Position.new(position)
      @score = 0
      @rolls = []
    end

    def turn(dice)
      3.times { rolls.push(dice.roll) }
      @score += position.move(rolls.last(3).sum)
    end

    def won?
      score >= game.winning_score
    end
  end

  class Game
    attr_reader :dice
    attr_reader :players
    attr_reader :winning_score

    def initialize(dice, initial_player_positions, winning_score)
      @dice = dice
      @players = initial_player_positions.map { |number, position| Player.new(self, number, position) }
      @winning_score = winning_score
    end

    def turn
      players.each do |player|
        player.turn(dice)
        return player if player.won?
      end

      nil
    end

    def complete?
      players.any?(&:won?)
    end

    def play
      until complete?
        turn
      end
    end

    def winning_player
      players.find(&:won?)
    end
  end

  #
  # I am apparently not smart enough to figure this out on my own. I implemented based on this nice
  # (Python) solution, implemented in Ruby without the aid of cache from functools (turns out the
  # memoization provided by @cache annotations is critical to the performance of this solution):
  #
  #   https://twitter.com/YassineAlouini/status/1473204161181270016
  #
  class QuantumSimulator
    DICE_ROLLS = [1,2,3].repeated_permutation(3).to_a.freeze

    attr_reader :cache

    def initialize(initial_player_positions, winning_score)
      @cache = {}
      @initial_player_positions = initial_player_positions
      @winning_score = winning_score
    end

    def store(*key, value)
      @cache[key] = value
    end

    def retrieve(*key)
      @cache[key]
    end

    def simulate(position1=@initial_player_positions[1], position2=@initial_player_positions[2], score1=0, score2=0)
      cached_value = retrieve(position1, position2, score1, score2)
      return cached_value if cached_value
      return store(position1, position2, score1, score2, [0, 1]) if score2 >= @winning_score

      winners = [0, 0]

      DICE_ROLLS.each do |dice|
        new_position1 = (position1 - 1 + dice.sum) % 10 + 1
        winners = winners.zip(simulate(position2, new_position1, score2, score1 + new_position1).reverse).map(&:sum)
      end

      store(position1, position2, score1, score2, winners)
    end
  end
end

input_file = ARGV.first
initial_player_positions = File.open(input_file).each_line.map do |line|
  if (m = /\APlayer (\d+) starting position: (\d+)\z/.match(line.chomp))
    [m[1].to_i, m[2].to_i]
  end
end

initial_player_positions = initial_player_positions.to_h

dice = DeterministicDice.new
game = Dirac::Game.new(dice, initial_player_positions, 1000)

game.play
losing_player_score = game.players.min_by(&:score).score
puts "Answer to part 1: #{losing_player_score * dice.rolls}"

simulator = Dirac::QuantumSimulator.new(initial_player_positions, 21)
winners = simulator.simulate

puts "Answer to part 2: #{winners.max}"
