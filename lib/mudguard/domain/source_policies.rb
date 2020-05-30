# frozen_string_literal: true

module Mudguard
  module Domain
    # Associates a source with it's policies
    SourcePolicies = Struct.new(:source, :policies, keyword_init: true)
  end
end
