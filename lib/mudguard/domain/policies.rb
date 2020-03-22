# frozen_string_literal: true

require_relative "ruby_analyser"

module Mudguard
  module Domain
    # Contains the policies to be enforced
    class Policies
      def initialize(policies: [])
        @policies = policies.map { |l| l.gsub(/\s/, "") }.map { |p| /^#{p}/ }
      end

      def check(sources, notification)
        result = check_sources(sources)

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

      def check_sources(sources)
        sources.each_with_object(count: 0, violations: 0) do |source, result|
          result[:count] += 1
          dependencies = RubyAnalyser.find_mod_dependencies(source)
          result[:violations] += check_dependencies(dependencies)
        end
      end

      def check_dependencies(dependencies)
        dependencies.reject { |d| @policies.any? { |p| d.match(p) } }.count
      end
    end
  end
end
