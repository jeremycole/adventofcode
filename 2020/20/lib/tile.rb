# frozen_string_literal: true

require 'image_data'

class Tile
  attr_reader :image, :number, :image_data

  POSSIBLE_FLIPS = %i[
    no_flip
    flip_horizontal
    flip_vertical
  ].freeze

  POSSIBLE_ROTATIONS = %i[
    no_rotate
    rotate_1
    rotate_2
    rotate_3
  ].freeze

  DUPLICATE_ORIENTATIONS = [
    [:flip_horizontal, :rotate_2],
    [:flip_horizontal, :rotate_3],
    [:flip_vertical, :rotate_2],
    [:flip_vertical, :rotate_3],
  ].freeze

  POSSIBLE_ORIENTATIONS = (POSSIBLE_FLIPS.product(POSSIBLE_ROTATIONS) - DUPLICATE_ORIENTATIONS).freeze

  def initialize(image, number, data)
    @image = image
    @number = number
    @image_data = ImageData.new(data)
  end

  def inspect
    "#<#{self.class.name} number=#{number}>"
  end

  def edge_identities
    @edge_identities ||= POSSIBLE_ORIENTATIONS.map do |flip, rotate|
      [[flip, rotate], image_data.send(flip).send(rotate).edge_identities]
    end.to_h
  end

  def unique_edge_identities
    @unique_edge_identities ||= edge_identities.values.flatten.uniq
  end

  def joins?(other_tile)
    return false if number == other_tile.number

    (unique_edge_identities & other_tile.unique_edge_identities).any?
  end

  def joinable_tiles
    image.joinable_tiles[self]
  end

  def transform(flip, rotate)
    @image_data = image_data.transform(flip, rotate)
  end
end
