# frozen_string_literal: true

require "yaml"
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

            yaml = YAML.load(File.read(policy_file), symbolize_names: true) || {}

            PolicyFile.new(yml: yaml)
          rescue Psych::SyntaxError => e
            raise Mudguard::Domain::Error, "#{policy_file} is invalid (#{e.message})"
          end

          private

          def only_comment?(line)
            line.match(/^\w*#/)
          end
        end

        def initialize(yml:)
          @yml = yml
        end

        def allowed_dependencies
          (@yml[:Dependencies] || []).map(&method(:unsymbolize))
        end

        def unsymbolize(dependency)
          if dependency.kind_of?(Symbol)
            ":#{dependency}"
          else
            dependency
          end
        end
      end
    end
  end
end
