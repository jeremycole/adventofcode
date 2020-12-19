class Operation
  attr_reader :op, :a, :b

  def initialize(op, a, b)
    @op = op
    @a = a
    @b = b
  end

  def to_i
    a.to_i.send(op, b.to_i)
  end

  def to_s
    [a.to_s, op.to_s, b.to_s].join(' ')
  end
end
