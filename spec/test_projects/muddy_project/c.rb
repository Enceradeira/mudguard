# frozen_string_literal: true

require_relative "a"

module B
  dependency2 = A::Klass
end
