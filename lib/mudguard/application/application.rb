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
        project = load_project(project_path)
        policies = project.policies
        policies.check(project.all_sources, notification)
      end

      def print_allowed_dependencies(project_path, notification)
        project = load_project(project_path)
        policies = project.policies
        policies.print_allowed_dependencies(project.all_sources, notification)
      end

      private

      def load_policy_file(project_path)
        policy_file_path = File.expand_path(".mudguard.yml", project_path)
        Infrastructure::Persistence::PolicyFile.read(policy_file_path)
      end

      def load_project(project_path)
        sources = Infrastructure::Persistence::RubyFiles.all(project_path)
        policy_file = load_policy_file(project_path)
        Domain::Project.new(sources: sources, policy_file: policy_file)
      end
    end
  end
end
