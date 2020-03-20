# frozen_string_literal: true

require_relative "b"

module A
  dependency = B::Klass
end
