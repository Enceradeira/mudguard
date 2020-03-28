# frozen_string_literal: true

require "pathname"
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

            enumerate_files(project_path)
          end

          private

          def enumerate_files(project_path)
            project_path_name = Pathname.new(project_path)
            ruby_files = File.join(project_path, "**", "*.rb")
            Dir.glob(ruby_files).map do |f|
              file_path_name = Pathname.new(f)
              diff_path = file_path_name.relative_path_from(project_path_name).to_s
              Mudguard::Domain::Source.new(location: File.join("./", diff_path), code: File.read(f))
            end.lazy
          end
        end
      end
    end
  end
end
