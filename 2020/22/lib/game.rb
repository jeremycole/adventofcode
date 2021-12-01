# frozen_string_literal: true

require 'player'

class Game
  attr_reader :players

  def initialize(filename)
    @players = []
    load_file(filename)
  end
  
  def load_file(filename)
    name = nil
    deck = nil
    File.open(filename).each_line do |line|
      case
      when (m = /Player (\d+)/.match(line))
        name = m[1].to_i
        deck = []
      when line == "\n"
        @players.push(Player.new(name, deck))
      else
        deck.push(line.to_i) if name
      end
    end
    @players.push(Player.new(name, deck)) if name
  end

  def finished?
    players.any?(&:finished?)
  end

  def turn
    return nil if finished?

    played = players.map { |player| [player, player.play_card] }.sort_by { |_, card| card }.reverse

    puts "played = #{played}"

    winner, _ = played.first

    winner.take_cards(played.map { |_, card| card })

    return winner
  end

  def play
    until finished?
      winner = turn
      puts "winner was #{winner.name}"
    end

    winner_score
  end

  def winner_score
    winner = players.reject(&:finished?).first
    [winner, winner.deck.reverse.each_with_index.map { |card, i| card * (i+1) }.sum]
  end
end
