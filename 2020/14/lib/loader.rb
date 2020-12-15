# frozen_string_literal: true

class Loader
  def self.load(filename, &block)
    loader = Loader.new

    File.open(filename).each_line do |line|
      case line
      when /^mask/
        m = /^mask = ([X01]+)/.match(line)
        raise "unparseable mask #{line}" unless m

        loader.set_mask(m[1])
      when /^mem/
        m = /^mem\[(\d+)\] = (\d+)/.match(line)
        raise "unparseable mem #{line}" unless m

        address = m[1].to_i
        value = m[2].to_i

        block.call(loader, address, value)
      end
    end

    loader
  end

  attr_reader :keep_mask, :over_mask, :memory

  def initialize
    @mask = ''
    @keep_mask = 0
    @over_mask = 0
    @memory = Hash.new(0)
  end

  def set_mask(str)
    @mask = str
    @keep_mask = str.tr('X01', '100').to_i(2)
    @over_mask = str.tr('X01', '001').to_i(2)
    @zero_mask = str.tr('X01', '011').to_i(2)
  end

  def apply_mask_for_part_one(value)
    (value & @keep_mask) | @over_mask
  end

  def load_value_to_address(address, value)
    @memory[address] = apply_mask_for_part_one(value)
  end

  def apply_mask_for_part_two(value)
    (value & @zero_mask) | @over_mask
  end

  def floating_bits
    @mask.split('').count { |c| c == 'X' }
  end

  def blend_floating_mask(bits)
    each_bit = bits.split('').each
    @mask.split('').map { |b| b == 'X' ? each_bit.next : b }.join
  end

  def all_addresses_for_mask(address)
    fb = floating_bits
    (0...(2**fb)).map do |x|
      apply_mask_for_part_two(address) | blend_floating_mask(format('%0*b', fb, x)).to_i(2)
    end
  end

  def load_value_to_many_addresses(address, value)
    all_addresses_for_mask(address).each do |actual_address|
      @memory[actual_address] = value
    end
  end
end
