# frozen_string_literal: true

require_relative "../infrastructure/persistence/policy_file"
require_relative "../infrastructure/persistence/ruby_files"
require_relative "../domain/policies"

# Contains methods to check if your project is a bit muddy
module Mudguard
  # API to mudguard
  module Application
    class << self
      def check(project_path, notification)
        create_policies_and_source(project_path) do |policies, sources|
          policies.check(sources, notification)
        end
      end

      def print_allowed_dependencies(project_path, notification)
        create_policies_and_source(project_path) do |policies, sources|
          policies.print_allowed_dependencies(sources, notification)
        end
      end

      private

      def create_policies_and_source(project_path)
        policy_file = load_policy_file(project_path)
        sources = load_sources(project_path, policy_file.excluded_files)
        policies = Domain::Policies.new(policies: policy_file.allowed_dependencies)
        yield policies, sources
      end

      def load_policy_file(project_path)
        policy_file_path = File.expand_path(".mudguard.yml", project_path)
        Infrastructure::Persistence::PolicyFile.read(policy_file_path)
      end

      def load_sources(project_path, excluded_files)
        all_sources = Infrastructure::Persistence::RubyFiles.select(project_path)
        excluded_source = Infrastructure::Persistence::RubyFiles.select(project_path,
                                                                        patterns: excluded_files)
        all_sources - excluded_source
      end
    end
  end
end
