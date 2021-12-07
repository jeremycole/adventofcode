class Card
  ROWS = 5
  COLS = 5

  attr_accessor :squares
  attr_accessor :last_marked_number
  attr_reader :card_number

  def self.read_from(file, card_number)
    board = new(card_number: card_number)

    ROWS.times.each do |row|
      line = file.readline
      line.split(" ").each_with_index do |value, col|
        board.set(row, col, value.to_i)
      end
    end

    board
  end

  def initialize(card_number: nil)
    @squares = ROWS.times.map { COLS.times.map { nil } }
    @marks = ROWS.times.map { COLS.times.map { false } }
    @card_number = card_number
  end

  def get(row, col)
    @squares[row][col]
  end

  def set(row, col, value)
    @squares[row][col] = value
  end

  def mark(row, col)
    @marks[row][col] = true
    @last_marked_number = @squares[row][col]
  end

  def take(number)
    @squares.each_with_index do |row, r|
      row.each_with_index do |value, c|
        mark(r, c) if value == number
      end
    end
  end

  def sum_of(state: true)
    ROWS.times.map { |r| COLS.times.map { |c| @marks[r][c] == state ? @squares[r][c] : 0 }.sum }.sum
  end

  def score
    sum_of(state: false) * @last_marked_number
  end

  def bingo?
    @marks.any?(&:all?) || @marks.transpose.any?(&:all?)
  end

  def to_s
    @squares.each_with_index.map do |row, r|
      row.each_with_index.map do |col, c|
        format("%s%3d%s",
          (@marks[r][c] ? "[" : " "),
          col,
          (@marks[r][c] ? "]" : " "))
      end.join
    end.join("\n")
  end
end

numbers = []
cards = []
card_number = 0
input_file = ARGV.shift
File.open(input_file) do |f|
  numbers = f.readline.split(",").map(&:to_i)

  until f.eof?
    f.readline
    cards << Card.read_from(f, card_number)
    card_number += 1
  end
end

puts "Drawn numbers: #{numbers.size}"

solved = []
numbers.each_with_index do |number, round|
  cards.reject(&:bingo?).each do |card|
    card.take(number)
    solved.push({card: card, round: round}) if card.bingo?
  end
end

puts "Cards:"
cards.each do |card|
  puts "Card #{card.card_number} (#{card.bingo? ? "BINGO" : "no bingo"}):"
  puts card
  puts
end

puts "Summary:"
puts "* Total cards: #{cards.size}"
puts "* Bingo: #{cards.map(&:bingo?).tally}"
puts

puts "Solved cards:"
solved.each_with_index do |solution, index|
  puts "* Bingo #{index}: round: #{solution[:round]}, card: #{solution[:card].card_number}, last marked number: #{solution[:card].last_marked_number}, score: #{solution[:card].score}"
end
puts

puts "Answer for part 1: #{solved.first&.dig(:card)&.score || "none"}"
puts "Answer for part 2: #{solved.last&.dig(:card)&.score || "none"}"


