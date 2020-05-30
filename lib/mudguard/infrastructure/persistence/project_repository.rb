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
              sources = RubyFiles.select(project_path, patterns: [patterns])
              sources.flat_map { |s| { source: s, policies: policies } }
            end

            sources = scopes.group_by { |e| e[:source] }

            sources.map do |source, group|
              policies = group.flat_map { |r| r[:policies] }.uniq
              Domain::SourcePolicies.new(source: source, policies: policies)
            end
          end
        end
      end
    end
  end
end
