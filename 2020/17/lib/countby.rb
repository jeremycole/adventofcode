class Countby
  def initialize
  end

  def each_number(n = 5)
    return to_enum(:each_number, n) unless block_given?

    100.times do |i|
      yield i * n
    end
  end
end