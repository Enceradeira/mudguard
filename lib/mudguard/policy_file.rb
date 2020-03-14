# frozen_string_literal: true

require_relative "policies"

module Mudguard
  # A file containing the Mudguard-Policies
  class PolicyFile
    def self.read(policy_file)
      policy_exists = File.exist?(policy_file)

      raise Error, "expected policy file #{policy_file} doesn't exists" unless policy_exists

      Policies.new(policies: File.readlines(policy_file))
    end
  end
end
