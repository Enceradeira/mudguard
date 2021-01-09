# frozen_string_literal: true

require "pathname"
require "mudguard/domain/source"

module Mudguard
  module Infrastructure
    module Persistence
      # Provides access to all ruby-files of a project
      class RubyFiles
        class << self
          def select(project_path, patterns: nil)
            project_exists = Dir.exist?(project_path)

            unless project_exists
              raise Mudguard::Domain::Error, "expected project #{project_path} doesn't exists"
            end

            patterns = [File.join("**", "*.rb")] if patterns.nil?
            enumerate_files(project_path, patterns)
          end

          private

          def enumerate_files(project_path, patterns)
            project_path_name = Pathname.new(project_path)
            ruby_files = patterns.map { |p| File.join(project_path, p) }
            Dir.glob(ruby_files).select { |f| File.file?(f) }.map do |f|
              file_path_name = Pathname.new(f)
              diff_path = file_path_name.relative_path_from(project_path_name).to_s
              Mudguard::Domain::Source.new(location: File.join("./", diff_path),
                                           code_loader: -> { File.read(f) })
            end
          end
        end
      end
    end
  end
end
