# frozen_string_literal: true

require 'vector'

class Ship
  attr_accessor :facing, :location, :waypoint

  DIRECTIONS = %i[N E S W].freeze
  DIRECTION_MAP = DIRECTIONS.each_with_index.to_h.freeze
  DIRECTION_VECTORS = {
    N: Vector.new(y: +1),
    E: Vector.new(x: +1),
    S: Vector.new(y: -1),
    W: Vector.new(x: -1),
  }.freeze
  TURNS = { R: +1, L: -1 }.freeze

  def initialize(facing: :E, location: Vector.new, waypoint: Vector.new)
    @facing = facing
    @location = location
    @waypoint = waypoint
  end

  def turn(direction, steps)
    self.facing = DIRECTIONS[(DIRECTION_MAP[facing] + (TURNS[direction] * steps)) % DIRECTIONS.size]
  end

  def move(direction, distance)
    self.location += DIRECTION_VECTORS[direction] * distance
  end

  def move_waypoint(direction, distance)
    self.waypoint += DIRECTION_VECTORS[direction] * distance
  end

  def move_to_waypoint
    self.location += waypoint
  end

  def rotate_waypoint(direction, steps)
    waypoint.rotate(TURNS[direction] * steps)
  end

  def parse_instruction(instruction)
    m = /^([NESWFRL])(\d+)$/.match(instruction)
    raise "couldn't parse #{instruction}" unless m

    action = m[1].to_sym
    operand = m[2].to_i

    [action, operand]
  end

  def execute_for_part_one(instruction)
    action, operand = parse_instruction(instruction)

    case action
    when :R, :L
      turn(action, operand / 90)
    when :F
      move(facing, operand)
    when :N, :E, :S, :W
      move(action, operand)
    else
      raise "unknown action #{action}"
    end
  end

  def execute_for_part_two(instruction)
    action, operand = parse_instruction(instruction)

    case action
    when :R, :L
      rotate_waypoint(action, operand / 90)
    when :F
      operand.times { move_to_waypoint }
    when :N, :E, :S, :W
      move_waypoint(action, operand)
    else
      raise "unknown action #{action}"
    end
  end
end
