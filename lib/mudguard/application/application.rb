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
        policies = load_policies(project_path)
        policies.check(all_files(project_path), notification)
      end

      def print_allowed_dependencies(project_path, notification)
        policies = load_policies(project_path)
        policies.print_allowed_dependencies(all_files(project_path), notification)
      end

      private

      def all_files(project_path)
        Infrastructure::Persistence::RubyFiles.all(project_path)
      end

      def load_policies(project_path)
        policy_file_path = File.expand_path(".mudguard.yml", project_path)
        policy_file = Infrastructure::Persistence::PolicyFile.read(policy_file_path)
        Mudguard::Domain::Policies.new(policies: policy_file.allowed_dependencies)
      end
    end
  end
end
