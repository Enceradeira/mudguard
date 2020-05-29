# frozen_string_literal: true

require "yaml"
require_relative "../../domain/policies"
require_relative "../../domain/error"
require_relative "../../domain/scope"

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
              raise Mudguard::Domain::Error, "expected policy file #{policy_file} doesn't exists"
            end

            yaml_file = File.read(policy_file)
            yaml = YAML.safe_load(yaml_file, [Symbol], [], policy_file) || {}

            create_scopes(project_path, yaml)
          rescue Psych::SyntaxError => e
            raise Mudguard::Domain::Error, "#{policy_file} is invalid (#{e.message})"
          end

          private

          def create_scopes(project_path, yml)
            yml.map do |scope|
              Domain::Scope.new(name: scope[0],
                                policies: (scope[1] || []).map(&method(:unsymbolize)),
                                sources: RubyFiles.select(project_path, patterns: [scope[0]]))
            end
          end

          def unsymbolize(dependency)
            if dependency.is_a?(Symbol)
              ":#{dependency}"
            else
              dependency
            end
          end

          def only_comment?(line)
            line.match(/^\w*#/)
          end
        end
      end
    end
  end
end
