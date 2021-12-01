def fuel_required(mass)
  return 0 unless mass.positive?

  [0, ((mass / 3) - 2)].max.tap { |x| puts x }
end

def fuel_for_mass(mass)
  return 0 unless mass.positive?

  fuel_required(mass).then { |fuel| fuel + fuel_for_mass(fuel) }
end

module_masses = File.open('input.txt').readlines.map(&:strip).map(&:to_i)

fuel_for_modules = module_masses.map { |mass| fuel_for_mass(mass) }.sum

puts fuel_for_modules
