# frozen_string_literal: true

require_relative "analyser"
require_relative "texts"

module Mudguard
  module Domain
    # Contains the policies to be enforced
    class Policies
      include Texts

      def initialize(policies: [])
        @policies = policies
      end

      def check(sources, notification)
        result = check_sources(sources, notification)

        count = result[:count]
        violations = result[:violations]

        notification.add(summary(count, violations))
        violations.zero?
      end

      private

      def check_sources(sources, notification)
        analyser = Analyser.new(policies: @policies, notification: notification)
        sources.each_with_object(count: 0, violations: 0) do |source, result|
          result[:count] += 1
          result[:violations] += analyser.check(source)
        end
      end
    end
  end
end
