# frozen_string_literal: true

require_relative "dependencies"
require_relative "texts"
require_relative "consts"

module Mudguard
  module Domain
    # Contains the policies to be enforced
    class Policies
      include Texts

      def initialize(policies: [])
        @policies = policies
      end

      def check(sources, notification)
        result = analyse(sources, :check, notification)

        count = result[:sources_count]
        violations = result[:analyser_count]

        notification.add(nil, summary(count, violations))
        violations.zero?
      end

      def print_allowed_dependencies(sources, notification)
        result = analyse(sources, :print_allowed, notification)

        count = result[:sources_count]
        violations = result[:analyser_count]

        notification.add(nil, dependency_summary(count, violations))
      end

      private

      def analyse(sources, method, notification)
        analyser = Dependencies.new(policies: @policies, notification: notification)
        consts = Consts.new(sources: sources)
        sources.each_with_object(sources_count: 0, analyser_count: 0) do |source, result|
          dependencies = source.find_mod_dependencies(consts)
          result[:sources_count] += 1
          result[:analyser_count] += analyser.send(method, dependencies)
        end
      end
    end
  end
end
