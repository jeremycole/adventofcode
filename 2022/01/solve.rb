#!/usr/bin/env ruby
# frozen_string_literal: true

elf_snacks = File.read(ARGV.first).split("\n\n").map { |x| x.split("\n").map(&:to_i) }
elf_calories = elf_snacks.map(&:sum)

puts elf_calories.max
puts elf_calories.sort.reverse.first(3).sum