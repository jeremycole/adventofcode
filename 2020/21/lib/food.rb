class Food
  attr_reader :ingredients, :allergens

  def self.parse(line)
    m = /^([a-z ]+) (?:\(contains (.+)\))?/.match(line)

    ingredients = m[1].split(' ')
    allergens = m[2]&.split(', ')

    Food.new(ingredients, allergens)
  end

  def initialize(ingredients, allergens)
    @ingredients = ingredients
    @allergens = allergens
  end

  def ingredient_possible_allergens
    ingredients.product(allergens)
  end
end
