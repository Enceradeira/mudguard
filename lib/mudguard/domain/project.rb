# frozen_string_literal: true

module Mudguard
  module Domain
    # Contains all artefacts of the project to be analysed
    class Project
      def initialize(sources:, policy_file:)
        @sources = sources
        @policy_file = policy_file
      end

      def all_sources
        @sources
      end

      def policies
        Mudguard::Domain::Policies.new(policies: @policy_file.allowed_dependencies)
      end
    end
  end
end
