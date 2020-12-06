# frozen_string_literal: true

class Group
  attr_reader :members

  def initialize
    @members = []
  end

  def add_member(answer_string)
    @members << answer_string.split('').sort
  end

  def unique_answers
    @members.reduce(:|).sort.uniq
  end

  def shared_answers
    @members.reduce(:&).sort.uniq
  end
end
