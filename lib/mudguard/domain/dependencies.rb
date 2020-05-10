# frozen_string_literal: true

require_relative "texts"

module Mudguard
  module Domain
    # Executes operation on a set of dependencies
    class Dependencies
      include Texts

      def initialize(policies:, notification:)
        @policies = policies.map { |p| /^#{p}/x }
        @notification = notification
      end

      def check(dependencies)
        select_dependencies(dependencies) do |dependency, is_allowed|
          @notification.add(dependency_not_allowed(dependency)) unless is_allowed
          !is_allowed
        end
      end

      def print_allowed(dependencies)
        select_dependencies(dependencies) do |dependency, is_allowed|
          @notification.add(dependency_allowed(dependency)) if is_allowed
          is_allowed
        end
      end

      private

      def select_dependencies(dependencies)
        dependencies.select do |dependency|
          yield dependency, dependency_allowed?(dependency)
        end.count
      end

      def dependency_allowed?(dependency)
        @policies.any? { |p| dependency.match(p) }
      end
    end
  end
end