# frozen_string_literal: true

module A
  class C
    class << self
      include ::D::E
    end
  end
end
