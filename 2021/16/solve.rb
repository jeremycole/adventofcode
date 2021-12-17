class Bitstream
  attr_reader :bits

  # Horribly inefficient for bitstream parsing, but YOLO.

  def initialize(message)
    @bits = message.split("").flat_map { |x| format("%04b", x.to_i(16)).split("") }
  end

  def read(n)
    bits.shift(n).join.to_i(2)
  end

  def size
    bits.size
  end
end

module Packet
  class Base
    attr_reader :version
    attr_reader :type

    def initialize(version, type, bitstream)
      @version = version
      @type = type
    end

    def version_sum
      version
    end
  end

  class Literal < Base
    attr_reader :value

    def initialize(version, type, bitstream)
      super
      @value = read_value(bitstream)
    end

    def read_value(bitstream)
      value = 0
      loop do
        remaining = bitstream.read(1)
        value <<= 4
        value |= bitstream.read(4)
        return value if remaining == 0
      end

      nil
    end

    def expr
      value.to_s
    end
  end

  class Operator < Base
    attr_reader :mode
    attr_reader :packets

    def initialize(version, type, bitstream)
      super

      @mode = bitstream.read(1)
      @packets = read_packets(bitstream)
    end

    def values
      packets.map(&:value)
    end

    def version_sum
      version + packets.map(&:version_sum).sum
    end

    def read_packets(bitstream)
      case mode
      when 0
        read_packets_by_bit_length(bitstream)
      when 1
        read_packets_by_packet_count(bitstream)
      else
        raise "Unknown mode #{mode}"
      end
    end

    def read_packets_by_bit_length(bitstream)
      bit_length = bitstream.read(15)
      ending_size = bitstream.size - bit_length
      packets = []
      while bitstream.size > ending_size
        packets << Packet.parse(bitstream)
      end
      packets
    end

    def read_packets_by_packet_count(bitstream)
      packet_count = bitstream.read(11)
      packet_count.times.map { Packet.parse(bitstream) }
    end
  end

  class Sum < Operator
    def value
      values.sum
    end

    def expr
      "(" + packets.map(&:expr).join(" + ") +  ")"
    end
  end

  class Product < Operator
    def value
      values.reduce(:*)
    end

    def expr
      "(" + packets.map(&:expr).join(" * ") +  ")"
    end
  end

  class Minimum < Operator
    def value
      values.min
    end

    def expr
      "min(" + packets.map(&:expr).join(", ") +  ")"
    end
  end

  class Maximum < Operator
    def value
      values.max
    end

    def expr
      "max(" + packets.map(&:expr).join(", ") +  ")"
    end
  end

  class Greater < Operator
    def value
      (values[0] > values[1]) ? 1 : 0
    end

    def expr
      "(" + packets.map(&:expr).join(" > ") +  ")"
    end
  end

  class Less < Operator
    def value
      (values[0] < values[1]) ? 1 : 0
    end

    def expr
      "(" + packets.map(&:expr).join(" < ") +  ")"
    end
  end

  class Equal < Operator
    def value
      (values[0] == values[1]) ? 1 : 0
    end

    def expr
      "(" + packets.map(&:expr).join(" == ") +  ")"
    end
  end

  TYPES = {
    0 => Sum,
    1 => Product,
    2 => Minimum,
    3 => Maximum,
    4 => Literal,
    5 => Greater,
    6 => Less,
    7 => Equal,
  }

  def self.parse(bitstream)
    version = bitstream.read(3)
    type = bitstream.read(3)

    packet_type = TYPES[type]
    raise "Unknown packet type #{type}" unless packet_type

    packet_type.new(version, type, bitstream)
  end
end

class Decoder
  attr_reader :bitstream

  def initialize(message)
    @bitstream = Bitstream.new(message)
  end

  def packet
    Packet.parse(bitstream)
  end
end

input_file = ARGV.shift
File.open(input_file).each_line do |line|
  decoder = Decoder.new(line.chomp)
  packet = decoder.packet
  puts "version sum = #{packet.version_sum}, value = #{packet.value}, expr = #{packet.expr}"
end