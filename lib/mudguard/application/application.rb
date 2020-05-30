# frozen_string_literal: true

require_relative "../infrastructure/persistence/project_repository"
require_relative "../domain/policies"

# Contains methods to check if your project is a bit muddy
module Mudguard
  # API to mudguard
  module Application
    class << self
      def check(project_path, notification)
        create_policies(project_path) do |policies|
          policies.check(notification)
        end
      end

      def print_allowed_dependencies(project_path, notification)
        create_policies(project_path) do |policies|
          policies.print_allowed_dependencies(notification)
        end
      end

      private

      def create_policies(project_path)
        repo = Infrastructure::Persistence::ProjectRepository
        source_policies = repo.load_source_policies(project_path)
        policies = Domain::Policies.new(source_policies: source_policies)
        yield policies
      end
    end
  end
end
