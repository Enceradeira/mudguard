# frozen_string_literal: true

require_relative "policy_file"
require_relative "ruby_files"
require_relative "../../domain/source_policies"

module Mudguard
  module Infrastructure
    module Persistence
      # Provides access to the persisted source and policies
      class ProjectRepository
        class << self
          def load_source_policies(project_path)
            file = PolicyFile.read(project_path)
            scopes = file.flat_map do |patterns, policies|
              build_scope(patterns, policies, project_path)
            end

            sources = scopes.group_by { |e| e[:source] }

            sources.map(&method(:build_policies))
          end

          private

          def build_policies(source, group)
            policies = group.flat_map { |r| r[:policies] }.uniq
            Domain::SourcePolicies.new(source: source, policies: policies)
          end

          def build_scope(patterns, policies, project_path)
            sources = RubyFiles.select(project_path, patterns: [patterns])
            sources.flat_map { |s| { source: s, policies: policies } }
          end
        end
      end
    end
  end
end
