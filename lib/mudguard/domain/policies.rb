# frozen_string_literal: true

module Mudguard
  module Domain
    # Contains the policies to be enforced
    class Policies
      def initialize(policies: [])
        @policies = policies.map { |l| l.gsub(/\s/, "") }.map { |p| /^#{p}/ }
      end

      def check(sources, notification)
        result = check_sources(sources, notification)

        count = result[:count]
        violations = result[:violations]

        files = pluralize("file", count)
        problems = pluralize("problem", violations)
        notification.add("#{count} #{files} inspected, #{violations} #{problems} detected")
        violations.zero?
      end

      private

      def pluralize(word, count)
        count == 1 ? word : "#{word}s"
      end

      def check_sources(sources, notification)
        sources.each_with_object(count: 0, violations: 0) do |source, result|
          result[:count] += 1
          dependencies = source.find_mod_dependencies
          result[:violations] += check_dependencies(dependencies, notification)
        end
      end

      def check_dependencies(dependencies, notification)
        dependencies.reject { |d| check_dependency(d, notification) }.count
      end

      def check_dependency(dependency, notification)
        is_allowed = @policies.any? { |p| dependency.match(p) }
        notification.add("#{dependency} not allowed") unless is_allowed
        is_allowed
      end
    end
  end
end
