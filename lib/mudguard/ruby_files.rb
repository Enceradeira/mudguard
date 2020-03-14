# frozen_string_literal: true

module Mudguard
  # Provides access to all ruby-files of a project
  class RubyFiles
    class << self
      def all(project_path)
        project_exists = Dir.exist?(project_path)

        raise Error, "expected project #{project_path} doesn't exists" unless project_exists

        ruby_files = File.join(project_path, "**", "*.rb")
        Dir.glob(ruby_files).lazy
      end
    end
  end
end
