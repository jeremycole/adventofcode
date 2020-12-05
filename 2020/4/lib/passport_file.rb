# frozen_string_literal: true

require 'passport'

class PassportFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def each_record
    return to_enum(:each_record) unless block_given?

    File.open(filename) do |file|
      record = []
      file.each_line do |line|
        if line == "\n"
          yield Passport.new(parse_record(record))
          record = []
        end

        record << line.strip
      end
    end
  end

  private

  def parse_record(record)
    record
      .flat_map { |fields| fields.split(' ') }
      .map { |field| field.split(':') }
      .map { |name, value| [name.to_sym, value] }
      .to_h
  end
end
