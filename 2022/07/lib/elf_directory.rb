# frozen_string_literal: true

class ElfDirectory
  attr_reader :parent
  attr_reader :name
  attr_reader :entries

  def initialize(parent = nil, name = nil)
    @parent = parent
    @name = name
    @entries = {}
  end

  def directory(name)
    entries[name] ||= ElfDirectory.new(self, name)
  end

  def add_file(name, size)
    entries[name] ||= ElfFile.new(name, size)
  end

  def size
    @entries.values.sum(&:size)
  end

  def each_directory
    return enum_for(:each_directory) unless block_given?

    entries.each do |name, entry|
      entry.each_directory { |d| yield d } if entry.is_a?(ElfDirectory)
    end

    yield self

    nil
  end
end
