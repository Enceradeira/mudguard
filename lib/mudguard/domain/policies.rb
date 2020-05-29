# frozen_string_literal: true

require_relative "dependencies"
require_relative "texts"
require_relative "consts"

module Mudguard
  module Domain
    # Contains the policies to be enforced
    class Policies
      include Texts

      def initialize(scopes: [])
        @scopes = scopes
      end

      def check(notification)
        result = analyse(:check, notification)

        count = result[:sources_count]
        violations = result[:analyser_count]

        notification.add(nil, summary(count, violations))
        violations.zero?
      end

      def print_allowed_dependencies(notification)
        result = analyse(:print_allowed, notification)

        count = result[:sources_count]
        violations = result[:analyser_count]

        notification.add(nil, dependency_summary(count, violations))
      end

      private

      def analyse(method, notification)
        consts = Consts.new(sources: @scopes.flat_map(&:sources))
        @scopes.each_with_object(sources_count: 0, analyser_count: 0) do |scope, scope_result|
          scope.sources.each_with_object(scope_result) do |source, source_result|
            analyser = Dependencies.new(policies: scope.dependencies, notification: notification)
            dependencies = source.find_mod_dependencies(consts)
            source_result[:sources_count] += 1
            source_result[:analyser_count] += analyser.send(method, dependencies)
          end
        end
      end
    end
  end
end
