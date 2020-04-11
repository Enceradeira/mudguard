# frozen_string_literal: true

require_relative "../../domain/policies"
require_relative "../../domain/error"

module Mudguard
  module Infrastructure
    module Persistence
      # A file containing the Mudguard-Policies
      class PolicyFile
        class << self
          def read(policy_file)
            policy_exists = File.exist?(policy_file)

            unless policy_exists
              raise Mudguard::Domain::Error, "expected policy file #{policy_file} doesn't exists"
            end

            File.readlines(policy_file)
                .map { |l| l.gsub(/\s/, "") }
                .reject(&:empty?)
                .reject(&method(:only_comment?))
          end

          private

          def only_comment?(line)
            line.match(/^\w*#/)
          end
        end
      end
    end
  end
end
