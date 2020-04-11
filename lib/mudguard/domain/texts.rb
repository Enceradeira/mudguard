# frozen_string_literal: true

module Mudguard
  module Domain
    # Builds texts to be displayed to a user
    module Texts
      def summary(file_count, violation_count)
        files = pluralize("file", file_count)
        problems = pluralize("problem", violation_count)
        "#{file_count} #{files} inspected, #{violation_count} #{problems} detected"
      end

      def dependency_not_allowed(dependency)
        "#{dependency} not allowed"
      end

      private

      def pluralize(word, count)
        count == 1 ? word : "#{word}s"
      end
    end
  end
end
