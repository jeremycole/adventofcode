# frozen_string_literal: true

class Message
  attr_reader :content

  def initialize(content)
    @content = content
  end

  def match(regexp)
    regexp.match(content)
  end
end
