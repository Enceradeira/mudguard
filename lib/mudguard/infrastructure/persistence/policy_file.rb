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
          def read(project_path)
            policy_file = File.join(project_path, ".mudguard.yml")
            policy_exists = File.exist?(policy_file)

            unless policy_exists
              template_file = File.join(__dir__, ".mudguard.template.yml")
              FileUtils.cp(template_file, policy_file)
            end

            read_yml(policy_file)
          end

          private

          def read_yml(policy_file)
            yaml_file = File.read(policy_file)
            yaml = YAML.safe_load(yaml_file, [Symbol], [], policy_file) || {}
            yaml.transform_values { |value| (value || []).map(&method(:unsymbolize)) }
          rescue Psych::SyntaxError => e
            raise Mudguard::Domain::Error, "#{policy_file} is invalid (#{e.message})"
          end

          def unsymbolize(dependency)
            if dependency.is_a?(Symbol)
              ":#{dependency}"
            else
              dependency
            end
          end
        end
      end
    end
  end
end
