require "gastar"

require "vector_3d"
require "matrix_3d"

ROTATION_ANGLES = [0, 1, 2, 3].map { |n| n * (Math::PI / 2) }
ORIENTATIONS = ROTATION_ANGLES.flat_map { |x| ROTATION_ANGLES.flat_map { |y| ROTATION_ANGLES.flat_map { |z| {x: x , y: y, z: z } } } }.uniq { |r| Vector3D.new(1, 2, 3).rotate(r).round.to_a }

class Beacon
  attr_reader :vector

  def initialize(scanner, vector)
    @scanner = scanner
    @vector = vector
  end

  def inspect
    "#<Beacon @ #{vector.to_a.map(&:round)}>"
  end

  def rotate(direction, orientation)
    case direction
    when :forward
      Beacon.new(@scanner, vector.rotate(orientation).round)
    when :reverse
      Beacon.new(@scanner, vector.reverse_rotate(**orientation).round)
    end
  end

  def translate(direction, t)
    case direction
    when :forward
      Beacon.new(@scanner, vector + t)
    when :reverse
      Beacon.new(@scanner, vector - t)
    end
  end

  def orientations
    ORIENTATIONS.map { |o| vector.rotate(:forward, o).round }
  end
end

class BeaconPair < Struct.new(:a, :b, :orientation, keyword_init: true)
  def vector
    @vector ||= (a.vector - b.vector).round
  end

  def magnitude
    @magnitude ||= vector.magnitude.round
  end

  def rotate(o)
    BeaconPair.new(a: a.rotate(:forward, o), b: b.rotate(:forward, o), orientation: o)
  end
end

class Scanner < AStarNode
  attr_reader :id
  attr_reader :location
  attr_reader :beacons

  def initialize(id)
    super()

    @id = id
    @location = Beacon.new(self, Vector3D.new(0, 0, 0))
    @beacons = []
  end

  def to_s
    "#<Scanner #{id} (#{beacons.size} beacons)>"
  end

  def inspect
    to_s
  end

  def push_beacon(vector)
    @beacons.push(Beacon.new(self, vector))
  end

  def forget_memoizations
    @beacon_pairs_by_distance = nil
    @beacon_pairs_by_vector = nil
    @distances = nil
  end

  def rotate(orientation_stack)
    old_beacons = @beacons
    forget_memoizations
    @beacons = old_beacons.map { |beacon| orientation_stack.inject(beacon) { |b, o| b.rotate(*o) } }
  end

  def translate(projection_stack)
    old_beacons = @beacons
    forget_memoizations
    @beacons = old_beacons.map { |beacon| projection_stack.inject(beacon) { |b, p| b.translate(*p) } }
    @location = projection_stack.inject(@location) { |b, (d, p)| b.translate(d == :forward ? :reverse : :forward, p) }
  end

  def beacon_pairs_by_distance
    @beacon_pairs_by_distance ||= calculate_beacon_pairs_by_distance
  end

  def calculate_beacon_pairs_by_distance
    beacons.combination(2).inject({}) do |h, (a, b)|
      bp = BeaconPair.new(a: a, b: b, orientation: ORIENTATIONS[0])
      h[bp.magnitude] ||= []
      h[bp.magnitude].push(bp)
      h
    end
  end

  def beacon_pairs_by_vector
    @beacon_pairs_by_vector ||= calculate_beacon_pairs_by_vector
  end

  def calculate_beacon_pairs_by_vector
    beacons.combination(2).inject({}) do |h, (a, b)|
      ORIENTATIONS.each do |o|
        [BeaconPair.new(a: a, b: b).rotate(o), BeaconPair.new(a: b, b: a).rotate(o)].each do |bp|
          h[bp.vector] ||= []
          h[bp.vector].push(bp)
        end
      end
      h
    end
  end

  def distances
    @distances ||= calculate_distances
  end

  def calculate_distances
    beacons.combination(2)
           .inject({}) { |h, (a, b)| h[a] ||= {}; h[b] ||= {}; h[a][b] = h[b][a] = (a.vector - b.vector).round; h }
  end

  def move_cost(other)
    1
  end
end

class ScannerResolverSearcher < AStar
  def initialize(scanners, map, maximize_cost = nil)
    graph = map.inject({}) { |h, (id, n)| h[scanners[id]] = n.keys.map { |sub_id| scanners[sub_id] }; h }

    super(graph)
  end

  def heuristic(node, start, goal)
    1
  end
end

def read_scanners(scanner_file)
  scanners = {}
  scanner = nil
  File.open(scanner_file).each_line do |line|
    if (m = /--- scanner (\d+) ---/.match(line))
      id = m[1].to_i
      scanner = scanners[id] = Scanner.new(id)
      next
    elsif !line.chomp.empty? && !scanner.nil?
      vector = Vector3D.new(*line.chomp.split(",").map(&:to_i))
      scanner.push_beacon(vector)
    end
  end
  scanners
end

def common_distances(a, b)
  a.beacon_pairs_by_distance.keys & b.beacon_pairs_by_distance.keys
end

def orientation_map(scanners)
  scanners.keys.combination(2).map { |a, b| [[a, b], common_distances(scanners[a], scanners[b]).flat_map { |d| scanners[a].beacon_pairs_by_distance[d].map(&:vector).flat_map { |v| scanners[b].beacon_pairs_by_vector[v] }.compact }.map(&:orientation).tally.max_by { |o, n| n } ] }.reject { |pair, o| o.nil? || o.last < 12 }.map { |(a, b), (o, _)| [a, [b, o]] }.inject({}) { |h, (a, (b, c))| h[a] ||= {}; h[a][b] ||= [:forward, c]; h[b] ||= {}; h[b][a] ||= [:reverse, c]; h }
end

def resolve(scanners, map, home=0)
  searcher = ScannerResolverSearcher.new(scanners, map) # .each_cons(2) { |a, b| map[a][b] }
  (scanners.keys - [home]).map { |id| [id, searcher.search(scanners[home], scanners[id])&.map(&:id)&.reverse&.each_cons(2)&.map { |a, b| map[b][a] } || []] }.to_h
end

def apply_queue(op, scanners, queue)
  queue.each do |scanner, stack|
    scanners[scanner].send(op, stack)
  end

  nil
end

def apply_orientations(scanners, orientations)
  apply_queue(:rotate, scanners, orientations)
end

def projection_map(scanners)
  scanners.keys.combination(2).map { |a, b| [[a, b], common_distances(scanners[a], scanners[b]).flat_map { |d| scanners[a].beacon_pairs_by_distance[d].product(scanners[b].beacon_pairs_by_distance[d]).select { |a, b| a.vector == b.vector }.map { |a, b| a.a.vector - b.a.vector } }.tally.max_by { |v, c| c } ] }.reject { |pair, p| p.nil? }.map { |(a, b), (o, _)| [a, [b, o]] }.inject({}) { |h, (a, (b, c))| h[a] ||= {}; h[a][b] ||= [:forward, c]; h[b] ||= {}; h[b][a] ||= [:reverse, c]; h }
end

def apply_projections(scanners, projections)
  apply_queue(:translate, scanners, projections)
end

input_file = ARGV.shift

puts "Loading scanner data from #{input_file}..."
scanners = read_scanners(input_file)

puts "Re-orienting..."
apply_orientations(scanners, resolve(scanners, orientation_map(scanners)))

puts "Translating..."
apply_projections(scanners, resolve(scanners, projection_map(scanners)))

puts "Calculating answers..."
unique_beacon_count = scanners.flat_map { |id, s| s.beacons.map(&:vector) }.uniq.size
maximum_inter_beacon_distance = scanners.values.map { |s| s.location.vector }.combination(2).map { |a, b| a.manhattan_distance(b).round }.max

puts "Answer to part 1: #{unique_beacon_count}"
puts "Answer to part 2: #{maximum_inter_beacon_distance}"