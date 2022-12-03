#!/usr/bin/env ruby
# frozen_string_literal: true

class Play
  ROCK_LETTER = "A"
  ROCK_SCORE = 1
  PAPER_LETTER = "B"
  PAPER_SCORE = 2
  SCISSORS_LETTER = "C"
  SCISSORS_SCORE = 3

  LOSS = 0
  TIE = 3
  WIN = 6

  DESIRE_LOSS = "X"
  DESIRE_TIE = "Y"
  DESIRE_WIN = "Z"

  LETTER_MAP = {
    ROCK_LETTER => ROCK_SCORE,
    PAPER_LETTER => PAPER_SCORE,
    SCISSORS_LETTER => SCISSORS_SCORE,
  }

  attr_reader :play

  def initialize(letter)
    @play = LETTER_MAP[letter]
  end

  def to_s
    "Play: #{play}"
  end

  def self.win(challenge)
    case challenge
    when ROCK_LETTER
      PAPER_LETTER
    when PAPER_LETTER
      SCISSORS_LETTER
    when SCISSORS_LETTER
      ROCK_LETTER
    end
  end

  def self.lose(challenge)
    case challenge
    when ROCK_LETTER
      SCISSORS_LETTER
    when PAPER_LETTER
      ROCK_LETTER
    when SCISSORS_LETTER
      PAPER_LETTER
    end
  end

  def self.counter_for_desired_outcome(challenge, outcome)
    case outcome
    when DESIRE_LOSS
      lose(challenge)
    when DESIRE_WIN
      win(challenge)
    when DESIRE_TIE
      challenge
    end
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

  def to_s
    "Play: #{challenge} vs #{play}"
  end
end

rounds = File.open(ARGV.shift).each_line.map do |line|
  challenge, outcome = line.chomp.split(/\s+/)

  Round.new(Play.new(challenge), Play.new(Play.counter_for_desired_outcome(challenge, outcome)))
end

puts rounds.map(&:score).sum