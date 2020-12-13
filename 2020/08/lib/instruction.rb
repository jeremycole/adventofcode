class Opcode
  attr_accessor :executions
  attr_reader :operand

  def initialize(operand = 0)
    @operand = operand
    @executions = 0
  end

  def mnemonic
    @mnemonic ||= self.class.name.split('::').last.downcase.to_sym
  end

  def to_s
    format('%s %+5d [%d]', mnemonic, operand, executions)
  end

  def execute(computer)
    self.executions += 1
    +1
  end
end

module Instruction
  class Nop < Opcode; end

  class Jmp < Opcode
    def execute(computer)
      super
      operand
    end
  end

  class Acc < Opcode
    def execute(computer)
      computer.accumulator += operand
      super
    end
  end

  OPCODES = {
    nop: Instruction::Nop,
    jmp: Instruction::Jmp,
    acc: Instruction::Acc
  }.freeze

  def self.parse(line)
    instruction, operand = line.split(' ')

    instruction = instruction.to_sym
    operand = operand.to_i

    return nil unless OPCODES.include?(instruction)

    OPCODES[instruction].new(operand)
  end
end