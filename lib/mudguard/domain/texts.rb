# frozen_string_literal: true

module Mudguard
  module Domain
    # Builds texts to be displayed to a user
    module Texts
      def summary(file_count, violation_count)
        files = pluralize("file", file_count)
        "#{file_count} #{files} inspected, #{count(violation_count)}\
 bad #{dependency(violation_count)} detected"
      end

      def dependency_not_allowed(dependency)
        "#{dependency} not allowed"
      end

      def dependency_summary(file_count, dependency_count)
        files = pluralize("file", file_count)
        "#{file_count} #{files} inspected, #{count(dependency_count)}\
 good #{dependency(dependency_count)} detected"
      end

      def dependency_allowed(dependency)
        dependency.to_s
      end

      private

      def dependency(count)
        count <= 1 ? "dependency" : "dependencies"
      end

      def count(count)
        count.zero? ? "no" : count.to_s
      end

      def pluralize(word, count)
        count == 1 ? word : "#{word}s"
      end
    end
  end
end
