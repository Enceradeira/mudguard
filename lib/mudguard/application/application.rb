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
        scopes = Infrastructure::Persistence::PolicyFile.read(project_path)
        policies = Domain::Policies.new(scopes: scopes)
        yield policies
      end
    end
  end
end
