# frozen_string_literal: true

require 'group'

class CustomsFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def each_group
    return to_enum(:each_group) unless block_given?

    File.open(filename) do |file|
      group = Group.new
      file.each_line do |line|
        if line == "\n"
          yield group
          group = Group.new
          next
        end

        group.add_member(line.strip)
      end
      yield group
    end

    nil
  end
end
