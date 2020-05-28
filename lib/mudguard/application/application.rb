# frozen_string_literal: true

require_relative "../infrastructure/persistence/policy_file"
require_relative "../infrastructure/persistence/ruby_files"
require_relative "../domain/policies"
require_relative "../domain/project"

# Contains methods to check if your project is a bit muddy
module Mudguard
  # API to mudguard
  module Application
    class << self
      def check(project_path, notification)
        policy_file = load_policy_file(project_path)
        policies = load_policies(policy_file)
        policies.check(load_project(project_path), notification)
      end

      def print_allowed_dependencies(project_path, notification)
        policy_file = load_policy_file(project_path)
        policies = load_policies(policy_file)
        policies.print_allowed_dependencies(load_project(project_path), notification)
      end

      private

      def load_policies(policy_file)
        Mudguard::Domain::Policies.new(policies: policy_file.allowed_dependencies)
      end

      def load_policy_file(project_path)
        policy_file_path = File.expand_path(".mudguard.yml", project_path)
        Infrastructure::Persistence::PolicyFile.read(policy_file_path)
      end

      def load_project(project_path)
        sources = Infrastructure::Persistence::RubyFiles.all(project_path)
        Domain::Project.new(sources: sources).all_sources
      end
    end
  end
end
