
def find_two(numbers)
  numbers.each do |i|
    numbers.each do |j|
      next unless (i + j) == 2020

      puts "#{i} * #{j} == #{i * j}"
      return
    end
  end
end

def find_three(numbers)
  numbers.each do |i|
    numbers.each do |j|
      numbers.each do |k|
        next unless (i + j + k) == 2020

        puts "#{i} * #{j} * #{k} == #{i * j * k}"
        return
      end
    end
  end
end

input_file = 'input.txt'
numbers = File.readlines(input_file).map(&:to_i).sort
puts "Read #{numbers.size} from #{input_file}"

find_two(numbers)
find_three(numbers)
