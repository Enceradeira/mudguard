# frozen_string_literal: true

require_relative "../../domain/policies"
require_relative "../../domain/error"

module Mudguard
  module Infrastructure
    module Persistence
      # A file containing the Mudguard-Policies
      class PolicyFile
        def self.read(policy_file)
          policy_exists = File.exist?(policy_file)

          unless policy_exists
            raise Mudguard::Domain::Error, "expected policy file #{policy_file} doesn't exists"
          end

          Mudguard::Domain::Policies.new(policies: File.readlines(policy_file))
        end
      end
    end
  end
end
