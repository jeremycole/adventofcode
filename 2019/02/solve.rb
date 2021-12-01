OPS = { 1 => :+, 2 => :* }

def execute_op(memory, op, a, b, r)
  #puts "#{op}, #{a}, #{b} -> #{r}"
  memory[r] = memory[a].send(op, memory[b])
end

def execute(memory)
  pc = 0

  while pc < memory.size
    #puts "pc = #{pc}"
    case memory[pc]
    when 1, 2
      execute_op(memory, OPS.fetch(memory[pc]), memory[pc+1], memory[pc+2], memory[pc+3])
    when 99 # exit
      return
    end
    pc += 4
  end
end

def execute_with_parameters(noun, verb)
  program = File.read('input.txt').split(',').map(&:to_i)
  program[1] = noun
  program[2] = verb
  execute(program)

  program[0]
end

def hunt_for_parameters(max_noun, max_verb, desired_result)
  (0..max_noun).each do |noun|
    (0..max_verb).each do |verb|
      result = execute_with_parameters(noun, verb)

      return [noun, verb] if result == desired_result
    end
  end

  nil
end

puts format(
  'result for 1202 is %d',
  execute_with_parameters(12, 2)
)

result = hunt_for_parameters(99, 99, 19690720)
puts "result for hunt is #{result || 'unknown'}"
