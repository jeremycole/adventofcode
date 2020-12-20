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
    str.strip.gsub('(', '( ').gsub(')', ' )').split(/\s+/).map do |t|
      case t
      when '*', '+'
        t.to_sym
      when '(', ')'
        t
      else
        t.to_i
      end
    end
  end

  def self.regroup(tokens)
    group = []
    while (token = tokens.shift)
      case token
      when '('
        group.push(regroup(tokens))
      when ')'
        return group
      else
        group.push(token)
      end
    end
    group
  end

  def self.bind(tokens, op)
    return tokens unless tokens.is_a?(Array)
    return tokens.map { |t| bind(t, op) } if tokens.size <= 3

    bound = []

    while tokens.any?
      if tokens[0] && tokens[1] == op && tokens[2]
        tokens.unshift(tokens.shift(3).map { |t| bind(t, op) })
      elsif tokens[0].is_a?(Array)
        bound.push(bind(tokens.shift, op))
      else
        bound.push(tokens.shift)
      end
    end

    bound
  end

  def self.parse(tokens)
    expression = Expression.new

    operands = []
    operator = nil
    while (token = tokens.shift)
      case token
      when Array
        operands.push(parse(token))
      when Integer, Expression
        operands.push(token)
      when Symbol
        operator = token
      else
        raise "unknown token #{token}"
      end

      next unless operands.size == 2

      operation = Operation.new(operator, operands.shift, operands.shift)
      operands = [expression.capture(operation)]
      operator = nil
    end

    expression.capture(operands.first) if operator.nil? && operands.size == 1

    expression
  end

  def self.parse_string(str, operator_precedence = [])
    tokens = regroup(tokenize(str))
    operator_precedence.each do |op|
      tokens = bind(tokens, op)
    end
    parse(tokens)
  end
end
