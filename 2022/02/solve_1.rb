#!/usr/bin/env ruby
# frozen_string_literal: true

class Play
  ROCK_SCORE = 1
  PAPER_SCORE = 2
  SCISSORS_SCORE = 3

  LOSS = 0
  TIE = 3
  WIN = 6

  LETTER_MAP = {
    "A" => ROCK_SCORE,
    "B" => PAPER_SCORE,
    "C" => SCISSORS_SCORE,
    "X" => ROCK_SCORE,
    "Y" => PAPER_SCORE,
    "Z" => SCISSORS_SCORE,
  }

  attr_reader :play

  def initialize(letter)
    @play = LETTER_MAP[letter]
  end

  def self.compare(a, b)
    return TIE if a == b
    return WIN if a == ROCK_SCORE && b == PAPER_SCORE
    return WIN if a == PAPER_SCORE && b == SCISSORS_SCORE
    return WIN if a == SCISSORS_SCORE && b == ROCK_SCORE

    LOSS
  end

  def challenge(other)
    self.class.compare(other.play, play) + play
  end
end

class Round
  attr_reader :challenge
  attr_reader :play

  def initialize(challenge, play)
    @challenge = challenge
    @play = play
  end

  def score
    play.challenge(challenge)
  end
end

rounds = File.open(ARGV.shift).each_line.map do |line|
  challenge, counter = line.chomp.split(/\s+/).map { |x| Play.new(x) }

  Round.new(challenge, counter)
end

puts rounds.map(&:score).sum