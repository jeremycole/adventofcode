require 'operation'

class Expression
  attr_accessor :root

  def initialize(root = 0)
    @root = root
  end

  def capture(root)
    self.root = root
  end

  def to_i
    root.to_i
  end

  def to_s
    ['(', root.to_s, ')'].join(' ')
  end

  def self.tokenize(str)
    str.strip.gsub('(', '( ').gsub(')', ' )').split(/\s+/)
  end

  def self.parse(tokens)
    expression = Expression.new

    operands = []
    operator = nil
    while (token = tokens.shift)
      case token
      when '('
        operands.push(parse(tokens))
      when ')'
        return expression
      when '*', '+'
        operator = token.to_sym
      when /[0-9]+/
        operands.push(token.to_i)
      else
        raise "unknown token #{token}"
      end

      next unless operands.size == 2

      operation = Operation.new(operator, operands.shift, operands.shift)
      operands = [expression.capture(operation)]
      operator = nil
    end

    expression
  end

  def self.parse_string(str)
    parse(tokenize(str))
  end
end
