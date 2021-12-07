
def elapse(ages)
  result = Hash.new(0)

  ages.each do |age, count|
    if age == 0
      result[6] += count
      result[8] += count
    else
      result[age-1] += count
    end
  end

  result
end

input_file = ARGV.shift
ages = Hash.new(0).merge(File.open(input_file).readline.split(",").map(&:to_i).tally)

puts format("Initial state: %s", ages)
256.times.each do |n|
  ages = elapse(ages)
  puts format("After %2i days: %s", n+1, ages)
end

puts "Total fish: #{ages.values.sum}"