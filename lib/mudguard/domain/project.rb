# frozen_string_literal: true

module Mudguard
  module Domain
    # Contains all artefacts of the project to be analysed
    class Project
      def initialize(sources:)
        @sources = sources
      end

      def all_sources
        @sources
      end
    end
  end
end
