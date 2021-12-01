# frozen_string_literal: true

class Player
  attr_reader :name, :deck

  def initialize(name, deck)
    @name = name
    @deck = deck
  end

  def finished?
    deck.none?
  end

  def play_card
    deck.shift
  end

  def take_cards(cards)
    deck.concat(cards)
  end
end
