# frozen_string_literal: true

require_relative "texts"

module Mudguard
  module Domain
    # Analyses a source and checks a set of policies
    class Analyser
      include Texts

      def initialize(policies:, notification:)
        @policies = policies.map { |p| /^#{p}/x }
        @notification = notification
      end

      def check(source, consts)
        check_dependencies(source.find_mod_dependencies(consts))
      end

      private

      def check_dependencies(dependencies)
        dependencies.reject { |d| dependency_allowed?(d) }.count
      end

      def dependency_allowed?(dependency)
        is_allowed = @policies.any? { |p| dependency.match(p) }
        @notification.add(dependency_not_allowed(dependency)) unless is_allowed
        is_allowed
      end
    end
  end
end
