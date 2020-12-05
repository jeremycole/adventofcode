# frozen_string_literal: true

class Passport
  VALIDATION_RULES = {
    byr: [/^\d{4}$/, 1920..2002],
    iyr: [/^\d{4}$/, 2010..2020],
    eyr: [/^\d{4}$/, 2020..2030],
    hgt: [
      /^\d+(cm|in)$/,
      proc { |x| x !~ /cm$/ || (x =~ /cm$/ && (150..193).include?(x.to_i)) },
      proc { |x| x !~ /in$/ || (x =~ /in$/ && (59..76).include?(x.to_i)) }
    ],
    hcl: [/^#[0-9a-f]{6}$/],
    ecl: [%w[amb blu brn gry grn hzl oth]],
    pid: [/^\d{9}$/],
    cid: []
  }.freeze

  EXPECTED_FIELDS = VALIDATION_RULES.keys.sort.freeze
  REQUIRED_FIELDS = (EXPECTED_FIELDS - %i[cid]).freeze

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def field_names
    data.keys.sort
  end

  def validate_field(name)
    value = data[name]
    violations = []
    VALIDATION_RULES[name].each do |rule|
      case rule
      when Regexp
        violations << rule unless rule.match(value)
      when Range
        violations << rule unless rule.include?(value.to_i)
      when Array
        violations << rule unless rule.include?(value)
      when Proc
        violations << rule unless rule.call(value)
      else
        raise StandardError, "unsupported rule type #{rule}"
      end
    end

    { valid: violations.empty?, value: value, violations: violations }
  end

  def validate
    field_names
      .map { |name| [name, validate_field(name)] }
      .reject { |_, validation| validation[:valid] }
      .to_h
  end

  def all_required_fields_present?
    (REQUIRED_FIELDS - field_names).empty?
  end

  def any_extra_fields_present?
    (field_names - EXPECTED_FIELDS).any?
  end

  def all_fields_valid?
    validate.empty?
  end

  def valid_for_part_one?
    all_required_fields_present? && !any_extra_fields_present?
  end

  def valid_for_part_two?
    valid_for_part_one? && all_fields_valid?
  end
end
