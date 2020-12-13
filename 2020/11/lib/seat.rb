require 'space'

class Seat < Space
  def initialize(layout, x, y)
    super
    @occupied = false
  end

  def occupied?
    @occupied
  end

  def occupiable?
    true
  end

  def to_s
    occupied? ? '#' : 'L'
  end

  def adjacent
    @adjacent ||= layout.adjacent_seats(self)
  end

  def visible
    @visible ||= layout.visible_seats(self)
  end

  def occupy
    @occupied = true
  end

  def empty
    @occupied = false
  end

  def toggle
    occupied? ? empty : occupy
  end
end
