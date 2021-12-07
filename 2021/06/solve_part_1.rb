
def elapse(fish)
  old_fish = []
  new_fish = []

  fish.each do |age|
    if age == 0
      old_fish << 6 # same fish
      new_fish << 8 # new fish
    else
      old_fish << age - 1
    end
  end

  old_fish + new_fish
end

input_file = ARGV.shift
fish = File.open(input_file).readline.split(",").map(&:to_i)

puts format("Initial state: %s", fish.join(","))
18.times.each do |n|
  fish = elapse(fish)
  puts format("After %2i days: %s", n+1, fish.join(","))
end

puts "Total fish: #{fish.count}"