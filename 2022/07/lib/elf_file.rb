# frozen_string_literal: true

class ElfFile
  attr_reader :name
  attr_reader :size

  def initialize(name, size)
    @name = name
    @size = size
  end
end
