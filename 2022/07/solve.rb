#!/usr/bin/env ruby
# frozen_string_literal: true

require "elf_filesystem"

root = ElfDirectory.new
current_directory = root
File.open(ARGV.first).each_line do |line|
  if matches = /^\$ cd (.+)/.match(line)
    case matches[1]
    when "/"
      current_directory = root
    when ".."
      current_directory = current_directory.parent
    else
      current_directory = current_directory.directory(matches[1])
    end
  elsif /^\$ ls/.match(line)
    # Nothing to do.
  elsif matches = /^dir (.+)/.match(line)
    current_directory.directory(matches[1]) # instantiate the directory if necessary
  elsif matches = /^(\d+) (.+)/.match(line)
    current_directory.add_file(matches[2], matches[1].to_i)
  end
end

puts root.each_directory.select { |d| d.size <= 100000 }.sum(&:size)

total_space = 70000000
required_unused_space = 30000000
needed_space = required_unused_space - (total_space - root.size)

deletion_candidate = root.each_directory.select { |d| d != root && d.size >= needed_space }.min_by(&:size)

puts deletion_candidate.size