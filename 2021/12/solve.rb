class Cave
  attr_reader :world
  attr_reader :name
  attr_reader :passages

  def initialize(world, name)
    @world = world
    @name = name
    @passages = {}
  end

  def connect(name)
    @passages[name] ||= world.cave(name)
  end

  def small?
    !start? && !end? && /\A[a-z]+\z/.match?(name)
  end

  def big?
    !start? && !end? && /\A[A-Z]+\z/.match?(name)
  end

  def start?
    name == "start"
  end

  def end?
    name == "end"
  end

  def revisitable?
    !start? && !end? && big?
  end

  def find_paths(paths=[], path=[])
    if end?
      paths.push(path + [self])
    else
      passages.each do |name, cave|
        if !path.include?(cave) || cave.revisitable?
          cave.find_paths(paths, path + [self])
        end
      end
    end

    paths
  end

  def dump(level=0, path=[])
    puts "#{"  " * level}cave: #{name}"
    passages.each do |name, cave|
      cave.dump(level+1, path + [self]) unless path.include?(cave)
    end

    nil
  end

  def to_s
    name
  end
end

class World
  attr_reader :caves

  def initialize
    @caves = {}
  end

  def cave(name)
    @caves[name] ||= Cave.new(self, name)
  end

  def start
    cave("start")
  end

  def dump
    start.dump
  end
end

world = World.new

input_file = ARGV.shift
File.open(input_file).each_line do |line|
  entry_name, exit_name = line.chomp.split("-")
  entry_cave = world.cave(entry_name)
  exit_cave = entry_cave.connect(exit_name)
  exit_cave.connect(entry_name)
end

puts world.dump

paths = world.start.find_paths

pp paths.map { |path| path.map(&:name).join(" -> ") }
puts "Answer to part 1: #{paths.size}"
