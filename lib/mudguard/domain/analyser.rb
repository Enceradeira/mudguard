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
        select_dependencies(source.find_mod_dependencies(consts)) do |dependency, is_allowed|
          @notification.add(dependency_not_allowed(dependency)) unless is_allowed
          !is_allowed
        end
      end

      def print_allowed_dependencies(source, consts)
        select_dependencies(source.find_mod_dependencies(consts)) do |dependency, is_allowed|
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
