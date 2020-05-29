# frozen_string_literal: true

module Mudguard
  module Domain
    # Defines a scope within a set of policies apply
    Scope = Struct.new(:name, :sources, :policies, keyword_init: true)
  end
end
