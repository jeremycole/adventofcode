require 'instruction'

class Computer
  attr_reader :filename, :instructions
  attr_accessor :pc, :accumulator, :trace, :last_pc

  def initialize(filename)
    @filename = filename
    @instructions = []
    @pc = 0
    @last_pc = 0
    @accumulator = 0
    @trace = false

    reset
  end

  def load_instructions
    @instructions = File.open(filename).readlines.map { |line| Instruction.parse(line) }
  end

  def reset
    load_instructions
    @pc = 0
    @last_pc = 0
    @accumulator = 0
  end

  def dump
    instructions.each_with_index do |instruction, i|
      puts format('%5d: %s', i, instruction)
    end
  end

  def next_instruction
    return nil if pc >= instructions.size

    instructions[pc]
  end

  def output_trace
    return unless trace

    puts format(
      '%-20s pc: %5d  last_pc: %5d',
      next_instruction || '(end)', pc, last_pc
    )
  end

  def step
    self.last_pc = pc
    self.pc += next_instruction.execute(self)
    output_trace
  end
end
