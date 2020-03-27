# frozen_string_literal: true

require "mudguard/domain/source"

module Mudguard
  module Infrastructure
    module Persistence
      # Provides access to all ruby-files of a project
      class RubyFiles
        class << self
          def all(project_path)
            project_exists = Dir.exist?(project_path)

            unless project_exists
              raise Mudguard::Domain::Error, "expected project #{project_path} doesn't exists"
            end

            ruby_files = File.join(project_path, "**", "*.rb")
            Dir.glob(ruby_files).map do |f|
              Mudguard::Domain::Source.new(location: f, code: File.read(f))
            end.lazy
          end
        end
      end
    end
  end
end
