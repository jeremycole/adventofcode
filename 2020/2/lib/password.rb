# frozen_string_literal: true

module Password
  class RangeRule
    attr_reader :letter, :range

    def initialize(letter:, args:)
      @letter = letter
      @range = Range.new(args[0].to_i, args[1].to_i)
    end

    def to_s
      "allow between #{range.min} and #{range.max} of #{letter}"
    end

    def password_letter_count(password, letter)
      password.split('').select { |l| l == letter }.count
    end

    def valid?(password)
      range.include?(password_letter_count(password, letter))
    end
  end

  class PositionRule
    attr_reader :letter, :positions

    def initialize(letter:, args:)
      @letter = letter
      @positions = args
    end

    def to_s
      "allow #{letter} in one of #{positions.join(', ')}"
    end

    def positions_letters(password)
      password.split('').each_with_index.select { |_, i| positions.include?(i + 1) }.map { |l, _| l }
    end

    def valid?(password)
      positions_letters(password).select { |l| l == letter }.count == 1
    end
  end

  class Line
    attr_reader :validator, :password

    def initialize(validator:, password:)
      @validator = validator
      @password = password
    end

    def valid?
      validator.valid?(password)
    end
  end

  class File
    def initialize(filename)
      @filename = filename
    end

    def each_with_validator(validator_class)
      return to_enum(:each_with_validator, validator_class) unless block_given?

      ::File.open('input.txt').each do |line|
        m = /(\d+)-(\d+) ([a-z]): (.*)/.match(line)
        next unless m

        yield Line.new(
          validator: validator_class.new(letter: m[3], args: [m[1].to_i, m[2].to_i]),
          password: m[4]
        )
      end

      nil
    end
  end
end
