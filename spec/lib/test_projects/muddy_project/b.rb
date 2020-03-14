# frozen_string_literal: true

require_relative "a"

module B
  dependency = A::Klass
end
