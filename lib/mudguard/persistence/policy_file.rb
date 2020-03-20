# frozen_string_literal: true

require_relative "../domain/policies"
require_relative "../domain/error"

module Mudguard
  module Persistence
    # A file containing the Mudguard-Policies
    class PolicyFile
      def self.read(policy_file)
        policy_exists = File.exist?(policy_file)

        raise Mudguard::Domain::Error, "expected policy file #{policy_file} doesn't exists" unless policy_exists

        Mudguard::Domain::Policies.new(policies: File.readlines(policy_file))
      end
    end
  end
end

